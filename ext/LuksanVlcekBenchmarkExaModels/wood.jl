@inline function LV.wood_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., nargs = Val(1))
    # Bind the unit scalar outside the generator: the closure then captures an
    # isbits value rather than Type{T}, which GPU broadcast kernels reject on
    # some targets.  `Fix2` keeps it a named type, so nothing anonymous reaches
    # the serialized core.
    o = T(1)
    EM.@add_var(c, x, N; start = Base.Generator(Base.Fix2(LV.wood_start, o), 1:N))
    con = EM.@add_con(c, LV.wood_constraint(x, k) for k in 1:N-7)
    EM.@add_con!(c, con, k => LV.wood_constraint_aug(x, k) for k in 1:N-7)
    EM.@add_obj(c, LV.wood_objective(x, i, T) for i = 1:N÷2-1)
    return c
end

@inline LV.wood_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.wood_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.wood_recipe(b; kwargs...), LV.wood_args(b, N)...; prod = prod)
