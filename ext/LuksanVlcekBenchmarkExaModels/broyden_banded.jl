@inline function LV.broyden_banded_recipe(
    ::LV.ExaModelsBackend; T = Float64, backend = nothing, kwargs...,
)
    c, N = EM.ExaCore(T; backend = backend, kwargs..., concrete = Val(true), nargs = Val(1))
    EM.@add_var(c, x, N; start = 3)
    EM.@add_var(c, y, N; start = 0)
    EM.@add_con(c, LV.broyden_banded_kconstraint(x, k) for k = 1:(N-1)÷2)
    EM.@add_con(c, y[1] - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 2))
    EM.@add_con(c, y[2] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1))
    EM.@add_con(c, y[3] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 4))
    EM.@add_con(c, y[4] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 4) - LV.broyden_banded_xi(x, 5))
    EM.@add_con(c, y[5] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 4) - LV.broyden_banded_xi(x, 5) - LV.broyden_banded_xi(x, 6))
    EM.@add_con(c, LV.broyden_banded_yconstraint(y, x, i) for i in 6:N-1)
    EM.@add_con(c, LV.broyden_banded_ylast(y, x, n) for n in N:N)
    EM.@add_obj(c, LV.broyden_banded_objective(x, y, i, T) for i in 1:N)
    return c
end

@inline LV.broyden_banded_args(::LV.ExaModelsBackend, N = 1000) = (N,)

@inline LV.broyden_banded_model(b::LV.ExaModelsBackend, N = 1000; prod = false, kwargs...) =
    EM.ExaModel(LV.broyden_banded_recipe(b; kwargs...), LV.broyden_banded_args(b, N)...; prod = prod)
