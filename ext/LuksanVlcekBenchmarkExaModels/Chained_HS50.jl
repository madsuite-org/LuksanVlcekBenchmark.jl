@inline function LV.Chained_HS50_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    nC    = 3 * (N - 1) ÷ 4
    It_L1 = [4 * div(i-1, 3) for i in 1:3:nC-3]
    It_L2 = [4 * div(i-1, 3) for i in 2:3:nC-3]
    It_L3 = [4 * div(i-1, 3) for i in 3:3:nC-3]
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = (LV.Chained_HS50_start(i) for i = 1:N))
    EM.@add_con(c, LV.Chained_HS50_constraint1(x, l) for l in It_L1)
    EM.@add_con(c, LV.Chained_HS50_constraint2(x, l) for l in It_L2)
    EM.@add_con(c, LV.Chained_HS50_constraint3(x, l) for l in It_L3)
    EM.@add_obj(c, LV.Chained_HS50_objective(x, i) for i in 1:floor(Int, (N-1)/4))
    return EM.ExaModel(c; prod = prod)
end

function LV.Chained_HS50_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    nC = 3 * (args - 1) ÷ 4
    It_L1 = [4 * div(i-1, 3) for i in 1:3:nC-3]
    It_L2 = [4 * div(i-1, 3) for i in 2:3:nC-3]
    It_L3 = [4 * div(i-1, 3) for i in 3:3:nC-3]
    EM.@add_var(c, x, args; start = (LV.Chained_HS50_start(i) for i = 1:args))
    EM.@add_con(c, LV.Chained_HS50_constraint1(x, l) for l in It_L1)
    EM.@add_con(c, LV.Chained_HS50_constraint2(x, l) for l in It_L2)
    EM.@add_con(c, LV.Chained_HS50_constraint3(x, l) for l in It_L3)
    EM.@add_obj(c, LV.Chained_HS50_objective(x, i) for i in 1:floor(Int, (args-1)/4))
    return c
end
