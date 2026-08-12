@inline function LV.broyden_tridiagonal_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = -1)
    EM.@add_con(c, LV.broyden_tridiagonal_constraint(x, k) for k = 1:N-4)
    EM.@add_obj(c, LV.broyden_tridiagonal_objective(x, i, T) for i = 2:N-1)
    EM.@add_obj(c, LV.broyden_tridiagonal_objective_boundary(x, n, T) for n in N:N)
    return c
end

@inline LV.broyden_tridiagonal_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.broyden_tridiagonal_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.broyden_tridiagonal_recipe(b; kwargs...), LV.broyden_tridiagonal_args(b, N)...; prod = prod)
