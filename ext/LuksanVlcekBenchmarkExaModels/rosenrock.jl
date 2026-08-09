@inline function LV.rosenrock_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = (LV.rosenrock_start(i) for i = 1:N))
    EM.@add_con(c, LV.rosenrock_constraint(x, i) for i = 1:N-2)
    EM.@add_obj(c, LV.rosenrock_objective(x, i) for i = 1:N-1)
    return EM.ExaModel(c; prod = prod)
end

function LV.rosenrock_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    EM.@add_var(c, x, args; start = (LV.rosenrock_start(i) for i = 1:args))
    EM.@add_con(c, LV.rosenrock_constraint(x, i) for i = 1:args-2)
    EM.@add_obj(c, LV.rosenrock_objective(x, i) for i = 1:args-1)
    return c
end
