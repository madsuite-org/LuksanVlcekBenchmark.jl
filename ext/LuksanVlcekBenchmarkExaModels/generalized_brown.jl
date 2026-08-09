@inline function LV.generalized_brown_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = fill(-1, N))
    EM.@add_con(c, LV.generalized_brown_constraint(x, k) for k = 1:N-2)
    EM.@add_obj(c, LV.generalized_brown_objective(x, i) for i = 1:N÷2)
    return EM.ExaModel(c; prod = prod)
end

function LV.generalized_brown_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    EM.@add_var(c, x, args; start = fill(-1, args))
    EM.@add_con(c, LV.generalized_brown_constraint(x, k) for k = 1:args-2)
    EM.@add_obj(c, LV.generalized_brown_objective(x, i) for i = 1:args÷2)
    return c
end
