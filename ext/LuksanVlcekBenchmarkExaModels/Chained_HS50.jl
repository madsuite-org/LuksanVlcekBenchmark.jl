@inline function LV.Chained_HS50_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = Base.Generator(LV.Chained_HS50_start, 1:N))
    EM.@add_con(c, LV.Chained_HS50_constraint1(x, l) for l in EM.ArgNode1(LV.Chained_HS50_l1, N))
    EM.@add_con(c, LV.Chained_HS50_constraint2(x, l) for l in EM.ArgNode1(LV.Chained_HS50_l2, N))
    EM.@add_con(c, LV.Chained_HS50_constraint3(x, l) for l in EM.ArgNode1(LV.Chained_HS50_l3, N))
    EM.@add_obj(c, LV.Chained_HS50_objective(x, i) for i in 1:floor(Int, (N-1)/4))
    return c
end

@inline LV.Chained_HS50_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.Chained_HS50_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.Chained_HS50_recipe(b; kwargs...), LV.Chained_HS50_args(b, N)...; prod = prod)
