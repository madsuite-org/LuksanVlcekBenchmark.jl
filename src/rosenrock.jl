# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.1

function rosenrock_model end
function rosenrock_recipe end
function rosenrock_args end
@inline rosenrock_start(i) = mod(i, 2) == 1 ? -1.2 : 1.0
@inline rosenrock_constraint(x, i) = 3x[i+1]^3 + 2 * x[i+2] - 5 + sin(x[i+1] - x[i+2])sin(x[i+1] + x[i+2]) + 4x[i+1] - x[i]exp(x[i] - x[i+1]) - 3
@inline rosenrock_objective(x, i) = 100 * (x[i]^2 - x[i+1])^2 + (x[i] - 1)^2
