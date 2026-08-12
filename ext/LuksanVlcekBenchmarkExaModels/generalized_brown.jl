@inline function LV.generalized_brown_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true), nargs = Val(1))
    EM.@add_var(c, x, N; start = -1)
    EM.@add_con(c, LV.generalized_brown_constraint(x, k) for k = 1:N-2)
    EM.@add_obj(c, LV.generalized_brown_objective(x, i) for i = 1:N÷2)
    return c
end

@inline LV.generalized_brown_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.generalized_brown_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.generalized_brown_recipe(b; kwargs...), LV.generalized_brown_args(b, N)...; prod = prod)
