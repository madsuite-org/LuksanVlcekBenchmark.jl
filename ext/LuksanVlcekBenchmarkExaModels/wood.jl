@inline function LV.wood_model(::LV.ExaModelsBackend, N = 1000; T = Float64, backend = nothing, prod = false, kwargs...)
    c = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true))
    # Bind start values as concrete T scalars so the broadcast closure stays
    # isbits — necessary for GPU backends (Metal rejects Type{T} in kernels).
    s_even, s_odd = T(0), T(-2)
    EM.@add_var(c, x, N; start = (iseven(i) ? s_even : s_odd for i = 1:N))
    con = EM.@add_con(c, LV.wood_constraint(x, k) for k in 1:N-7)
    EM.@add_con!(c, con, k => LV.wood_constraint_aug(x, k) for k in 1:N-7)
    EM.@add_obj(c, LV.wood_objective(x, i, T) for i = 1:N÷2-1)
    return EM.ExaModel(c; prod = prod)
end
