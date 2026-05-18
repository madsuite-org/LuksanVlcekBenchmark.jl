@inline function LV.augmented_lagrangian_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    h  = T(1) / T(N + 1)
    l1 = T(LV.augmented_lagrangian_l1)
    l2 = T(LV.augmented_lagrangian_l2)
    l3 = T(LV.augmented_lagrangian_l3)
    # Bind start values as concrete T scalars so the broadcast closure stays
    # isbits (Metal/oneAPI reject Type{T} captures in kernels).
    s_even, s_odd = T(2), T(-1)
    c  = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    EM.@add_var(c, x, N; start = (mod(i, 2) == 1 ? s_odd : s_even for i = 1:N))
    EM.@add_con(c, LV.augmented_lagrangian_constraint(x, h, k, T) for k = 1:N-2)
    EM.@add_obj(c, LV.augmented_lagrangian_objective(x, l1, l2, l3, i) for i = 1:N÷5)
    return EM.ExaModel(c; prod = prod)
end
