@inline function LV.augmented_lagrangian_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    l1 = T(LV.augmented_lagrangian_l1)
    l2 = T(LV.augmented_lagrangian_l2)
    l3 = T(LV.augmented_lagrangian_l3)
    # Bind the unit scalar outside the generator (see wood.jl).
    o = T(1)
    EM.@add_var(c, x, N; start = Base.Generator(Base.Fix2(LV.augmented_lagrangian_start, o), 1:N))
    # `h` depends on the size, so it cannot be a number here.  It is per-row data
    # rather than structure: the row set carries `(k, h)` and the kernel reads
    # both off the element, which is the same idiom an ordinary model would use.
    EM.@add_con(
        c,
        LV.augmented_lagrangian_constraint(x, p.h, p.k, T) for
        p in EM.ArgNode1(Base.Fix2(LV.augmented_lagrangian_rows, o), N)
    )
    EM.@add_obj(c, LV.augmented_lagrangian_objective(x, l1, l2, l3, i) for i = 1:N÷5)
    return c
end

@inline LV.augmented_lagrangian_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.augmented_lagrangian_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.augmented_lagrangian_recipe(b; kwargs...), LV.augmented_lagrangian_args(b, N)...; prod = prod)
