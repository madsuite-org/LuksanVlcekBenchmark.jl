@inline function LV.broyden_banded_model(::LV.JuMPBackend, N = 1000; optimizer = nothing, kwargs...)
    n = Int(N)
    m = optimizer === nothing ? JuMP.Model() : JuMP.Model(optimizer)
    JuMP.@variable(m, x[1:N])
    JuMP.@variable(m, y[1:N])
    for i in 1:N
        JuMP.set_start_value(x[i], 3.0)
        JuMP.set_start_value(y[i], 0.0)
    end
    JuMP.@constraint(m, [k = 1:(N-1)÷2], LV.broyden_banded_kconstraint(x, k) == 0)
    JuMP.@constraint(m, y[1] - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 2) == 0)
    JuMP.@constraint(m, y[2] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) == 0)
    JuMP.@constraint(m, y[3] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 4) == 0)
    JuMP.@constraint(m, y[4] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 4) - LV.broyden_banded_xi(x, 5) == 0)
    JuMP.@constraint(m, y[5] - LV.broyden_banded_xi(x, 2) - LV.broyden_banded_xi(x, 3) - LV.broyden_banded_xi(x, 1) - LV.broyden_banded_xi(x, 4) - LV.broyden_banded_xi(x, 5) - LV.broyden_banded_xi(x, 6) == 0)
    JuMP.@constraint(m, [i = 6:N-1], LV.broyden_banded_yconstraint(y, x, i) == 0)
    JuMP.@constraint(m, LV.broyden_banded_ylast(y, x, n) == 0)
    JuMP.@objective(m, Min, sum(LV.broyden_banded_objective(x, y, i) for i in 1:N))
    return m
end
