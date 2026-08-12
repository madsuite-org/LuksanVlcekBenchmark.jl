# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.10

function generalized_brown_model end
function generalized_brown_recipe end
function generalized_brown_args end
@inline generalized_brown_constraint(x, k) = (3 - 2 * x[k+1]) * x[k+1] + 1 - x[k] - 2 * x[k+2]
@inline generalized_brown_objective(x, i) = (x[2i-1]^2)^(x[2i]^2 + 1) + (x[2i]^2)^(x[2i-1]^2 + 1)
