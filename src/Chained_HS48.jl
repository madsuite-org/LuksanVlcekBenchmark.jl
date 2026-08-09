# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.13
# The index in nC would be out of range; the last constraint is therefore not implemented.

function Chained_HS48_model end
function Chained_HS48_core end
@inline Chained_HS48_start(i) = mod(i, 3) == 1 ? 3.0 : mod(i, 3) == 2 ? 5.0 : -3.0
@inline Chained_HS48_constraint1(x, l) = x[l+1] + x[l+2]^2 + x[l+3] + x[l+4] + x[l+5] - 5
@inline Chained_HS48_constraint2(x, l) = x[l+3]^2 - 2 * (x[l+4] + x[l+5]) - 3
@inline Chained_HS48_objective(x, i) = (x[3(i-1)+1] - 1)^2 + (x[3(i-1)+2] - x[3(i-1)+3])^2 +
    (x[3(i-1)+4] - x[3(i-1)+5])^2
