@inline function LV.broyden_tridiagonal_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = fill(-1, N))
    EM.@add_con(c, LV.broyden_tridiagonal_constraint(x, k) for k = 1:N-4)
    EM.@add_obj(c, LV.broyden_tridiagonal_objective(x, i, T) for i = 2:N-1)
    EM.@add_obj(c, LV.broyden_tridiagonal_objective_boundary(x, N, T))
    return EM.ExaModel(c; prod = prod)
end

function LV.broyden_tridiagonal_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    EM.@add_var(c, x, args; start = fill(-1, args))
    EM.@add_con(c, LV.broyden_tridiagonal_constraint(x, k) for k = 1:args-4)
    EM.@add_obj(c, LV.broyden_tridiagonal_objective(x, i) for i = 2:args-1)
    EM.@add_obj(c, LV.broyden_tridiagonal_objective_boundary(x, n) for n in args:args)
    return c
end
