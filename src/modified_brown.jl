# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.9

function modified_brown_model end
@inline modified_brown_constraint1(x) = 4 * (x[1] - x[2]^2) + x[2] - x[3]^2 + x[3] - x[4]^2
@inline modified_brown_constraint2(x) = 8 * x[2] * (x[2]^2 - x[1]) - 2 * (1 - x[2]) + 4 * (x[2] - x[3]^2) + x[1]^2 + x[3] - x[4]^2 + x[4] - x[5]^2
@inline modified_brown_constraint3(x) = 8 * x[3] * (x[3]^2 - x[2]) - 2 * (1 - x[3]) + 4 * (x[3] - x[4]^2) + x[2]^2 - x[1] + x[4] - x[5]^2 + x[1]^2 + x[5] - x[6]^2
@inline modified_brown_constraint4(x, n) = 8 * x[n-2] * (x[n-2]^2 - x[n-3]) - 2 * (1 - x[n-2]) + 4 * (x[n-2] - x[n-1]^2) + x[n-3]^2 - x[n-4] + x[n-1] - x[n]^2 + x[n-4]^2 + x[n] - x[n-5]
@inline modified_brown_constraint5(x, n) = 8 * x[n-1] * (x[n-1]^2 - x[n-2]) - 2 * (1 - x[n-1]) + 4 * (x[n-1] - x[n]^2) + x[n-2]^2 - x[n-3] + x[n] + x[n-3]^2 - x[n-4]
@inline modified_brown_constraint6(x, n) = 8 * x[n] * (x[n]^2 - x[n-1]) - 2 * (1 - x[n]) + x[n-1]^2 - x[n-2] + x[n-2]^2 - x[n-3]
@inline modified_brown_objective(x, i) = (x[2i-1] - 3)^2 / 1000 - (x[2i-1] - x[2i]) + exp(20 * (x[2i-1] - x[2i]))
# T-aware overload: avoids Float64 inv(1000) constant in the derivative when T is Float32.
@inline modified_brown_objective(x, i, ::Type{T}) where {T} = (x[2i-1] - 3)^2 / T(1000) - (x[2i-1] - x[2i]) + exp(20 * (x[2i-1] - x[2i]))
