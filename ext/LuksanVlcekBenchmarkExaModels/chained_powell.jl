@inline function LV.chained_powell_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = (LV.chained_powell_start(i) for i = 1:N))
    EM.@add_con(c, LV.chained_powell_constraint1(x))
    EM.@add_con(c, LV.chained_powell_constraint2(x, N))
    EM.@add_obj(c, LV.chained_powell_objective(x, i) for i = 1:N÷2-1)
    return EM.ExaModel(c; prod = prod)
end

function LV.chained_powell_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    EM.@add_var(c, x, args; start = (LV.chained_powell_start(i) for i = 1:args))
    EM.@add_con(c, LV.chained_powell_constraint1(x) for _ in 1:1)
    EM.@add_con(c, LV.chained_powell_constraint2(x, n) for n in args:args)
    EM.@add_obj(c, LV.chained_powell_objective(x, i) for i = 1:args÷2-1)
    return c
end
