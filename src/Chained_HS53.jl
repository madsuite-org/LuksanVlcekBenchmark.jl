# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.18
# The index in nC would be out of range; the last term in each constraint is therefore not implemented.

function Chained_HS53_model end
function Chained_HS53_recipe end
function Chained_HS53_args end

# Constraint index sets — see the note in Chained_HS46.jl.
@inline Chained_HS53_nC(N) = 3 * (N - 1) ÷ 4
Chained_HS53_l1(N) = [4 * div(i-1, 3) for i in 1:3:Chained_HS53_nC(N)-3]
Chained_HS53_l2(N) = [4 * div(i-1, 3) for i in 2:3:Chained_HS53_nC(N)-3]
Chained_HS53_l3(N) = [4 * div(i-1, 3) for i in 3:3:Chained_HS53_nC(N)-3]
@inline Chained_HS53_start(i) = 2.0
@inline Chained_HS53_constraint1(x, l) = x[l+1]^2 + 3 * x[l+2]
@inline Chained_HS53_constraint2(x, l) = x[l+3]^2 + 2 * x[l+4] - 2 * x[l+5]
@inline Chained_HS53_constraint3(x, l) = x[l+2]^2 - x[l+5]
@inline Chained_HS53_objective(x, i) = (x[4(i-1)+1] - x[4(i-1)+2])^4 + (x[4(i-1)+2] + x[4(i-1)+3] - 2)^2 +
    (x[4(i-1)+4] - 1)^2 + (x[4(i-1)+5] - 1)^2
