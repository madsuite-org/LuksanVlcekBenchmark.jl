@inline function LV.Chained_HS48_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = Base.Generator(LV.Chained_HS48_start, 1:N))
    EM.@add_con(c, LV.Chained_HS48_constraint1(x, l) for l in EM.ArgNode1(LV.Chained_HS48_l1, N))
    EM.@add_con(c, LV.Chained_HS48_constraint2(x, l) for l in EM.ArgNode1(LV.Chained_HS48_l2, N))
    EM.@add_obj(c, LV.Chained_HS48_objective(x, i) for i in 1:floor(Int, (N-2)/3))
    return c
end

@inline LV.Chained_HS48_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.Chained_HS48_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.Chained_HS48_recipe(b; kwargs...), LV.Chained_HS48_args(b, N)...; prod = prod)
