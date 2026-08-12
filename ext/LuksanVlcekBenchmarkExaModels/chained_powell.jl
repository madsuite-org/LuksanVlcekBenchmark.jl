@inline function LV.chained_powell_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    EM.@add_var(c, x, N; start = Base.Generator(LV.chained_powell_start, 1:N))
    EM.@add_con(c, LV.chained_powell_constraint1(x))
    # One row, but it indexes the last variable — so the index arrives as data
    # from a one-element set rather than as a number the structure has to know.
    EM.@add_con(c, LV.chained_powell_constraint2(x, n) for n in N:N)
    EM.@add_obj(c, LV.chained_powell_objective(x, i) for i = 1:N÷2-1)
    return c
end

@inline LV.chained_powell_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.chained_powell_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.chained_powell_recipe(b; kwargs...), LV.chained_powell_args(b, N)...; prod = prod)
