using Test
using ExaModels
using JuMP
using NLPModels
using MadNLP
using KernelAbstractions
using SparseArrays
using LuksanVlcekBenchmark
using CUDA
using LuksanVlcekBenchmark: ExaModelsBackend, JuMPBackend

# Build list of ExaModels backends to test
const BACKENDS = Any[nothing, CPU()]

if CUDA.functional()
    push!(BACKENDS, CUDABackend())
    @info "CUDA backend enabled"
end

# Small N for test speed
const N_TEST = 100

function make_exa_model(model_func, N, backend)
    if backend === nothing
        return model_func(ExaModelsBackend(), N; prod = true)
    else
        return model_func(ExaModelsBackend(), N; backend = backend, prod = true)
    end
end

# Constraint order is representation-dependent: the native models and the
# JuMP-converted reference may declare the same constraints in different order.
# Match rows by their (residual, Jacobian row) signature; returns p such that
# row p[i] of the tested model corresponds to reference row i, or nothing.
function row_permutation(Jw, rw, Jref, rref; atol = 1e-8)
    n = length(rref)
    used = falses(n)
    p = zeros(Int, n)
    for i = 1:n
        found = 0
        for j = 1:n
            used[j] && continue
            if isapprox(rw[j], rref[i]; atol = atol) &&
               isapprox(view(Jw, j, :), view(Jref, i, :); atol = atol)
                found = j
                break
            end
        end
        found == 0 && return nothing
        used[found] = true
        p[i] = found
    end
    return p
end

function test_model(name, model_func)
    @testset "$name" begin
        # Build JuMP model once and convert to ExaModel for callback reference
        m_jump = model_func(JuMPBackend(), N_TEST)
        @test m_jump isa JuMP.Model
        m_ref = ExaModels.ExaModel(m_jump; prod = true)

        nvar   = get_nvar(m_ref)
        ncon   = get_ncon(m_ref)
        nnzj   = get_nnzj(m_ref)
        nnzh   = get_nnzh(m_ref)
        x0     = copy(get_x0(m_ref))
        # Nonzero multipliers so the Lagrangian Hessian comparison covers the
        # constraints' second-order terms and jtprod is nontrivial (both are
        # sums over constraints, hence invariant to constraint order).
        y0     = ones(Float64, ncon)

        # Reference sparse structures
        jac_rows_ref = zeros(Int, nnzj);  jac_cols_ref = zeros(Int, nnzj)
        hess_rows_ref = zeros(Int, nnzh); hess_cols_ref = zeros(Int, nnzh)
        jac_structure!(m_ref, jac_rows_ref, jac_cols_ref)
        hess_structure!(m_ref, hess_rows_ref, hess_cols_ref)
        jac_vals_ref  = zeros(Float64, nnzj)
        hess_vals_ref = zeros(Float64, nnzh)
        jac_coord!(m_ref, x0, jac_vals_ref)
        hess_coord!(m_ref, x0, y0, hess_vals_ref)
        J_ref = sparse(jac_rows_ref, jac_cols_ref, jac_vals_ref, ncon, nvar)
        H_ref = sparse(hess_rows_ref, hess_cols_ref, hess_vals_ref, nvar, nvar)

        # Solve JuMP model with MadNLP as reference
        r_ref = madnlp(m_ref; print_level = MadNLP.ERROR)

        for backend in BACKENDS
            @testset "backend=$backend" begin
                m_exa = make_exa_model(model_func, N_TEST, backend)
                @test m_exa isa ExaModels.ExaModel

                # WrapperNLPModel copies GPU results to CPU for uniform access
                m_w = ExaModels.WrapperNLPModel(m_exa)

                # Dimension check.  nnzj/nnzh are deliberately NOT compared:
                # the partially compressed COO length is representation-dependent,
                # so the native models and the JuMP-converted reference may carry
                # different duplicate counts; the assembled matrices are compared
                # below instead.
                @test get_nvar(m_w) == nvar
                @test get_ncon(m_w) == ncon

                # --- Callback accuracy vs JuMP reference ---
                @test NLPModels.obj(m_w, x0) ≈ NLPModels.obj(m_ref, x0) atol = 1e-6 rtol = 1e-8
                @test NLPModels.grad(m_w, x0) ≈ NLPModels.grad(m_ref, x0) atol = 1e-6 rtol = 1e-8
                if ncon > 0
                    @test NLPModels.jtprod(m_w, x0, y0) ≈ NLPModels.jtprod(m_ref, x0, y0) atol = 1e-6 rtol = 1e-8
                    @test NLPModels.hprod(m_w, x0, y0, x0) ≈ NLPModels.hprod(m_ref, x0, y0, x0) atol = 1e-6 rtol = 1e-8
                end

                # --- Row-space comparisons: residuals, jprod, Jacobian ---
                # Compare bound-relative residuals (JuMP moves constraint
                # constants into lcon/ucon, the native models keep them in the
                # body) after matching rows, since constraint order is
                # representation-dependent.
                if ncon > 0
                    nnzj_w = get_nnzj(m_w)
                    jac_rows = zeros(Int, nnzj_w); jac_cols = zeros(Int, nnzj_w)
                    jac_structure!(m_w, jac_rows, jac_cols)
                    jac_vals = zeros(Float64, nnzj_w)
                    jac_coord!(m_w, x0, jac_vals)
                    J = Matrix(sparse(jac_rows, jac_cols, jac_vals, ncon, nvar))
                    Jr = Matrix(J_ref)
                    resid_w = NLPModels.cons(m_w, x0) .- NLPModels.get_lcon(m_w)
                    resid_ref = NLPModels.cons(m_ref, x0) .- NLPModels.get_lcon(m_ref)
                    p = row_permutation(J, resid_w, Jr, resid_ref; atol = 1e-6)
                    @test p !== nothing
                    if p !== nothing
                        @test resid_w[p] ≈ resid_ref atol = 1e-6 rtol = 1e-8
                        @test NLPModels.jprod(m_w, x0, x0)[p] ≈ NLPModels.jprod(m_ref, x0, x0) atol = 1e-6 rtol = 1e-8
                        @test J[p, :] ≈ Jr atol = 1e-6 rtol = 1e-8
                    end
                end

                # --- Hessian structure and values ---
                nnzh_w = get_nnzh(m_w)
                hess_rows = zeros(Int, nnzh_w); hess_cols = zeros(Int, nnzh_w)
                hess_structure!(m_w, hess_rows, hess_cols)
                hess_vals = zeros(Float64, nnzh_w)
                hess_coord!(m_w, x0, y0, hess_vals)
                H = sparse(hess_rows, hess_cols, hess_vals, nvar, nvar)
                @test Matrix(H) ≈ Matrix(H_ref) atol = 1e-6 rtol = 1e-8

                # --- Solver convergence ---
                # Model identity is established by the pointwise callback and
                # matrix comparisons above.  The converged point is NOT compared
                # across representations: these problems are nonconvex, and
                # constraint ordering and platform rounding can steer the
                # interior-point iterates into different local minima (observed
                # for cragg_levy: same model, different basins on x64 vs arm64).
                r_exa = madnlp(m_exa; print_level = MadNLP.ERROR)
                @test r_exa.status == MadNLP.SOLVE_SUCCEEDED
                @test r_ref.status == MadNLP.SOLVE_SUCCEEDED
            end
        end
    end
end

# ── Lazy-core construction ───────────────────────────────────────────────────
# Each `*_core()` builds the model once against the ArgTracer size sentinel;
# `ExaModels.ExaModel(core, n)` materializes it at any size. The builders call
# the same LV.* expression functions in the same order as the direct ExaModels
# constructors, so the materialized model must match the direct model
# numerically (assembled Jacobian/Hessian compared densely, so entry order
# within the compressed sparsity need not agree).
function test_core_model(name, core_func, model_func)
    @testset "core: $name" begin
        core = core_func()
        m_core = ExaModels.ExaModel(core, N_TEST)   # bare value binds the direct tracer
        m_dir = model_func(ExaModelsBackend(), N_TEST)

        nvar = get_nvar(m_dir)
        ncon = get_ncon(m_dir)
        @test get_nvar(m_core) == nvar
        @test get_ncon(m_core) == ncon

        x0 = copy(get_x0(m_dir))
        @test get_x0(m_core) ≈ x0 atol = 1e-12
        @test NLPModels.get_lvar(m_core) == NLPModels.get_lvar(m_dir)
        @test NLPModels.get_uvar(m_core) == NLPModels.get_uvar(m_dir)
        @test NLPModels.get_lcon(m_core) == NLPModels.get_lcon(m_dir)
        @test NLPModels.get_ucon(m_core) == NLPModels.get_ucon(m_dir)

        y0 = ones(Float64, ncon)
        @test NLPModels.obj(m_core, x0) ≈ NLPModels.obj(m_dir, x0) atol = 1e-8 rtol = 1e-10
        @test NLPModels.grad(m_core, x0) ≈ NLPModels.grad(m_dir, x0) atol = 1e-8 rtol = 1e-10
        if ncon > 0
            @test NLPModels.cons(m_core, x0) ≈ NLPModels.cons(m_dir, x0) atol = 1e-8 rtol = 1e-10
            J_t = jac_dense(m_core, x0, nvar, ncon)
            J_d = jac_dense(m_dir, x0, nvar, ncon)
            @test J_t ≈ J_d atol = 1e-8 rtol = 1e-10
        end
        H_t = hess_dense(m_core, x0, y0, nvar)
        H_d = hess_dense(m_dir, x0, y0, nvar)
        @test H_t ≈ H_d atol = 1e-8 rtol = 1e-10

        r_core = madnlp(m_core; print_level = MadNLP.ERROR)
        @test r_core.status == MadNLP.SOLVE_SUCCEEDED
    end
end

function jac_dense(m, x, nvar, ncon)
    nnz = get_nnzj(m)
    rows = zeros(Int, nnz); cols = zeros(Int, nnz); vals = zeros(Float64, nnz)
    jac_structure!(m, rows, cols)
    jac_coord!(m, x, vals)
    return Matrix(sparse(rows, cols, vals, ncon, nvar))
end

function hess_dense(m, x, y, nvar)
    nnz = get_nnzh(m)
    rows = zeros(Int, nnz); cols = zeros(Int, nnz); vals = zeros(Float64, nnz)
    hess_structure!(m, rows, cols)
    hess_coord!(m, x, y, vals)
    return Matrix(sparse(rows, cols, vals, nvar, nvar))
end

function runtests()
    @testset "LuksanVlcekBenchmark" begin
        for name in LuksanVlcekBenchmark.NAMES
            model_func = getfield(LuksanVlcekBenchmark, name)
            test_model(string(name), model_func)
        end
        @testset "lazy-core construction" begin
            for name in LuksanVlcekBenchmark.CORE_NAMES
                model_name = Symbol(replace(string(name), r"core$" => "model"))
                test_core_model(
                    string(name),
                    getfield(LuksanVlcekBenchmark, name),
                    getfield(LuksanVlcekBenchmark, model_name),
                )
            end
        end
    end
end

runtests()
