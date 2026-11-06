const NLPModels = EM.NLPModels

# Model types do not depend on the size, so one small size covers the CPU.  A
# device also needs a large one: above one thread block, building and evaluating
# a model launches kernels that a small size does not.
const PRECOMPILE_SIZES = (100, 100_000)

# Calls made through `invokelatest`, as from the top level, so that each is
# compiled as a standalone method rather than only inlined into the workload.
_call(f, args...; kw...) = Base.invokelatest(f, args...; kw...)

function _evaluate_callbacks(m)
    x = copy(NLPModels.get_x0(m))
    ncon, nnzj, nnzh = NLPModels.get_ncon(m), NLPModels.get_nnzj(m), NLPModels.get_nnzh(m)
    y = fill!(similar(x, ncon), one(eltype(x)))
    _call(NLPModels.jac_structure!, m, similar(x, Int, nnzj), similar(x, Int, nnzj))
    _call(NLPModels.hess_structure!, m, similar(x, Int, nnzh), similar(x, Int, nnzh))
    _call(NLPModels.obj, m, x)
    _call(NLPModels.grad!, m, x, similar(x))
    _call(NLPModels.cons!, m, x, similar(x, ncon))
    _call(NLPModels.jac_coord!, m, x, similar(x, nnzj))
    _call(NLPModels.hess_coord!, m, x, y, similar(x, nnzh))
    return nothing
end

function LV._precompile_workload(backend; T = nothing)
    kw = backend === nothing ? (;) : (; backend)
    kw = T === nothing ? kw : (; kw..., T)
    sizes = backend === nothing ? PRECOMPILE_SIZES[1:1] : PRECOMPILE_SIZES
    for name in LV.NAMES
        endswith(string(name), "_model") || continue
        try
            model = getfield(LV, name)
            for N in sizes
                _evaluate_callbacks(_call(model, LV.ExaModelsBackend(), N; kw...))
            end
        catch err
            @warn "skipping $name in the package image" exception = err
        end
    end
    return nothing
end

PrecompileTools.@compile_workload begin
    if LV.PRECOMPILE
        LV._precompile_workload(nothing)
    end
end
