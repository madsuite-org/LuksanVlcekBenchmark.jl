# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.13
# The index in nC would be out of range; the last constraint is therefore not implemented.

function Chained_HS48_model end
function Chained_HS48_recipe end
function Chained_HS48_args end

# Constraint index sets.  These were comprehensions inside the constructor; a
# recipe cannot write one, because the size they run over is not known when the
# structure is built.  As named functions they can be deferred and run once, on
# the instantiated size.  `nC` and the strides are exactly as they were.
@inline Chained_HS48_nC(N) = 2 * (N - 2) ÷ 3
Chained_HS48_l1(N) = [3 * div(i-1, 2) for i in 1:2:Chained_HS48_nC(N)-1]
Chained_HS48_l2(N) = [3 * div(i-1, 2) for i in 2:2:Chained_HS48_nC(N)]
@inline Chained_HS48_start(i) = mod(i, 3) == 1 ? 3.0 : mod(i, 3) == 2 ? 5.0 : -3.0
@inline Chained_HS48_constraint1(x, l) = x[l+1] + x[l+2]^2 + x[l+3] + x[l+4] + x[l+5] - 5
@inline Chained_HS48_constraint2(x, l) = x[l+3]^2 - 2 * (x[l+4] + x[l+5]) - 3
@inline Chained_HS48_objective(x, i) = (x[3(i-1)+1] - 1)^2 + (x[3(i-1)+2] - x[3(i-1)+3])^2 +
    (x[3(i-1)+4] - x[3(i-1)+5])^2
