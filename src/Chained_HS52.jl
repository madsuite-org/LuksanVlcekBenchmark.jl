# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.17
# The index in nC would be out of range; the last term in each constraint is therefore not implemented.

function Chained_HS52_model end
function Chained_HS52_core end
@inline Chained_HS52_start(i) = 2.0
@inline Chained_HS52_constraint1(x, l) = x[l+1]^2 + 3 * x[l+2]
@inline Chained_HS52_constraint2(x, l) = x[l+3]^2 + 2 * x[l+4] - 2 * x[l+5]
@inline Chained_HS52_constraint3(x, l) = x[l+2]^2 - x[l+5]
@inline Chained_HS52_objective(x, i) = (4 * x[4(i-1)+1] - x[4(i-1)+2])^2 + (x[4(i-1)+2] + x[4(i-1)+3] - 2)^4 +
    (x[4(i-1)+4] - 1)^2 + (x[4(i-1)+5] - 1)^2
