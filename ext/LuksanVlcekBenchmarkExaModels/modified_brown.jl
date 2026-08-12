@inline function LV.modified_brown_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = -1)
    EM.@add_con(c, LV.modified_brown_constraint1(x))
    EM.@add_con(c, LV.modified_brown_constraint2(x))
    EM.@add_con(c, LV.modified_brown_constraint3(x))
    # The trailing three rows index from the end (see chained_powell.jl).
    EM.@add_con(c, LV.modified_brown_constraint4(x, n) for n in N:N)
    EM.@add_con(c, LV.modified_brown_constraint5(x, n) for n in N:N)
    EM.@add_con(c, LV.modified_brown_constraint6(x, n) for n in N:N)
    EM.@add_obj(c, LV.modified_brown_objective(x, i, T) for i = 1:N÷2)
    return c
end

@inline LV.modified_brown_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.modified_brown_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.modified_brown_recipe(b; kwargs...), LV.modified_brown_args(b, N)...; prod = prod)
