@inline function LV.rosenrock_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true), nargs = Val(1))
    EM.@add_var(c, x, N; start = Base.Generator(LV.rosenrock_start, 1:N))
    EM.@add_con(c, LV.rosenrock_constraint(x, i) for i = 1:N-2)
    EM.@add_obj(c, LV.rosenrock_objective(x, i) for i = 1:N-1)
    return c
end

@inline LV.rosenrock_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.rosenrock_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.rosenrock_recipe(b; kwargs...), LV.rosenrock_args(b, N)...; prod = prod)
