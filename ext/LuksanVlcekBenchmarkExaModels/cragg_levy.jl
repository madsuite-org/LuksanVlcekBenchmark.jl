@inline function LV.cragg_levy_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = Base.Generator(LV.cragg_levy_start, 1:N))
    EM.@add_con(c, LV.cragg_levy_constraint(x, k) for k = 1:N-2)
    EM.@add_obj(c, LV.cragg_levy_objective(x, i) for i = 1:N÷2-1)
    return c
end

@inline LV.cragg_levy_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.cragg_levy_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.cragg_levy_recipe(b; kwargs...), LV.cragg_levy_args(b, N)...; prod = prod)
