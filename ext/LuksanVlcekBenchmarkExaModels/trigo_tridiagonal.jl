@inline function LV.trigo_tridiagonal_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    n = N
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = fill(1, N))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint1(x))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint2(x))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint3(x, n))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint4(x, n))
    EM.@add_obj(c, LV.trigo_tridiagonal_objective(x, i) for i = 2:N-1)
    return EM.ExaModel(c; prod = prod)
end

function LV.trigo_tridiagonal_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    EM.@add_var(c, x, args; start = fill(1, args))
    EM.@add_con(c, LV.trigo_tridiagonal_constraint1(x) for _ in 1:1)
    EM.@add_con(c, LV.trigo_tridiagonal_constraint2(x) for _ in 1:1)
    EM.@add_con(c, LV.trigo_tridiagonal_constraint3(x, n) for n in args:args)
    EM.@add_con(c, LV.trigo_tridiagonal_constraint4(x, n) for n in args:args)
    EM.@add_obj(c, LV.trigo_tridiagonal_objective(x, i) for i = 2:args-1)
    return c
end
