# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.7

function trigo_tridiagonal_model end
function trigo_tridiagonal_recipe end
function trigo_tridiagonal_args end
@inline trigo_tridiagonal_constraint1(x) = 4 * (x[1] - x[2]^2) + x[2] - x[3]^2
@inline trigo_tridiagonal_constraint2(x) = 8 * x[2] * (x[2]^2 - x[1]) - 2 * (1 - x[2]) + 4 * (x[2] - x[3]^2) + x[3] - x[4]^2
@inline trigo_tridiagonal_constraint3(x, n) = 8 * x[n-1] * (x[n-1]^2 - x[n-2]) - 2 * (1 - x[n-1]) + 4 * (x[n-1] - x[n]^2) + x[n-2] - x[n-3]^2
@inline trigo_tridiagonal_constraint4(x, n) = 8 * x[n] * (x[n]^2 - x[n-1]) - 2 * (1 - x[n]) + x[n-1]^2 - x[n-2]
@inline trigo_tridiagonal_objective(x, i) = i * (1 - cos(x[i]) + sin(x[i-1]) - sin(x[i+1]))
