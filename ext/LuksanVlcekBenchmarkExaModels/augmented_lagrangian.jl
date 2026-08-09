@inline function LV.augmented_lagrangian_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    h  = T(1) / T(N + 1)
    l1 = T(LV.augmented_lagrangian_l1)
    l2 = T(LV.augmented_lagrangian_l2)
    l3 = T(LV.augmented_lagrangian_l3)
    c  = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    # Bind the unit scalar outside the generator (see wood.jl).
    o = T(1)
    EM.@add_var(c, x, N; start = (LV.augmented_lagrangian_start(i, o) for i = 1:N))
    EM.@add_con(c, LV.augmented_lagrangian_constraint(x, h, k, T) for k = 1:N-2)
    EM.@add_obj(c, LV.augmented_lagrangian_objective(x, l1, l2, l3, i) for i = 1:N÷5)
    return EM.ExaModel(c; prod = prod)
end

function LV.augmented_lagrangian_core()
    args = EM.ArgTracer()
    c = EM.ExaCore(concrete = Val(true))
    h = 1 / (args + 1)
    EM.@add_var(c, x, args; start = (LV.augmented_lagrangian_start(i) for i = 1:args))
    EM.@add_con(c, LV.augmented_lagrangian_constraint(x, h, k) for k = 1:args-2)
    EM.@add_obj(c, LV.augmented_lagrangian_objective(
        x, LV.augmented_lagrangian_l1, LV.augmented_lagrangian_l2,
        LV.augmented_lagrangian_l3, i) for i = 1:args÷5)
    return c
end
