# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.11
# The index in nC would be out of range for constraints where mod(k,2)==1; the last constraint is therefore not implemented.

function Chained_HS46_model end
function Chained_HS46_core end
@inline Chained_HS46_start(i) = mod(i, 3) == 1 ? 2.0 : mod(i, 3) == 2 ? 1.5 : 0.5
@inline Chained_HS46_constraint1(x, l) = x[l+2] + x[l+3]^4 * x[l+4]^2 - 2
@inline Chained_HS46_constraint2(x, l) = x[l+1]^2 * x[l+4] + sin(x[l+4] - x[l+5]) - 1
@inline Chained_HS46_objective(x, i) = (x[3(i-1)+1] - x[3(i-1)+2])^2 + (x[3(i-1)+3] - 1)^2 +
    (x[3(i-1)+4] - 1)^4 + (x[3(i-1)+5] - 1)^6
