# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.4

function cragg_levy_model end
function cragg_levy_recipe end
function cragg_levy_args end
@inline cragg_levy_start(i) = mod(i, 4) == 1 ? 1.0 : 2.0
@inline cragg_levy_constraint(x, k) = 8 * x[k+1] * (x[k+1]^2 - x[k]) - 2 * (1 - x[k+1]) + 4 * (x[k+1] - x[k+2]^2)
@inline cragg_levy_objective(x, i) = (exp(x[2i-1]) - x[2i])^4 + 100 * (x[2i] - x[2i+1])^6 +
    tan(x[2i+1] - x[2i+2])^4 + 8 * x[2i-1]^8 + (x[2i+2] - 1)^2
