@inline function LV.trigo_tridiagonal_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = 1)
    EM.@add_con(c, LV.trigo_tridiagonal_constraint1(x))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint2(x))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint3(x, n) for n in N:N)
    EM.@add_con(c, LV.trigo_tridiagonal_constraint4(x, n) for n in N:N)
    EM.@add_obj(c, LV.trigo_tridiagonal_objective(x, i) for i = 2:N-1)
    return c
end

@inline LV.trigo_tridiagonal_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.trigo_tridiagonal_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.trigo_tridiagonal_recipe(b; kwargs...), LV.trigo_tridiagonal_args(b, N)...; prod = prod)
