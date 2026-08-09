@inline function LV.Chained_HS48_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    nC    = 2 * (N - 2) ÷ 3
    It_L1 = [3 * div(i-1, 2) for i in 1:2:nC-1]
    It_L2 = [3 * div(i-1, 2) for i in 2:2:nC]
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = (LV.Chained_HS48_start(i) for i = 1:N))
    EM.@add_con(c, LV.Chained_HS48_constraint1(x, l) for l in It_L1)
    EM.@add_con(c, LV.Chained_HS48_constraint2(x, l) for l in It_L2)
    EM.@add_obj(c, LV.Chained_HS48_objective(x, i) for i in 1:floor(Int, (N-2)/3))
    return EM.ExaModel(c; prod = prod)
end

function LV.Chained_HS48_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    nC = 2 * (args - 2) ÷ 3
    It_L1 = [3 * div(i-1, 2) for i in 1:2:nC-1]
    It_L2 = [3 * div(i-1, 2) for i in 2:2:nC]
    EM.@add_var(c, x, args; start = (LV.Chained_HS48_start(i) for i = 1:args))
    EM.@add_con(c, LV.Chained_HS48_constraint1(x, l) for l in It_L1)
    EM.@add_con(c, LV.Chained_HS48_constraint2(x, l) for l in It_L2)
    EM.@add_obj(c, LV.Chained_HS48_objective(x, i) for i in 1:floor(Int, (args-2)/3))
    return c
end
