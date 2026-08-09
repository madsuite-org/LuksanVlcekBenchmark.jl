# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.16
# The index in nC would be out of range; the last term in each constraint is therefore not implemented.

function Chained_HS51_model end
function Chained_HS51_core end
@inline Chained_HS51_start(i) = mod(i, 4) == 1 ? 2.5 : mod(i, 4) == 2 ? 0.5 : mod(i, 4) == 3 ? 2.0 : -1.0
@inline Chained_HS51_constraint1(x, l) = x[l+1]^2 + 3 * x[l+2] - 4
@inline Chained_HS51_constraint2(x, l) = x[l+3]^2 + 2 * x[l+4] - 2 * x[l+5]
@inline Chained_HS51_constraint3(x, l) = x[l+2]^2 - x[l+5]
@inline Chained_HS51_objective(x, i) = (x[4(i-1)+1] - x[4(i-1)+2])^4 + (x[4(i-1)+2] + x[4(i-1)+3] - 2)^2 +
    (x[4(i-1)+4] - 1)^2 + (x[4(i-1)+5] - 1)^2
