# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.8

function augmented_lagrangian_model end
@inline augmented_lagrangian_start(i) = mod(i, 2) == 1 ? -1.0 : 2.0
@inline augmented_lagrangian_start(i, ::Type{T}) where {T} = mod(i, 2) == 1 ? T(-1) : T(2)
const augmented_lagrangian_l1 = -0.002008
const augmented_lagrangian_l2 = -0.001900
const augmented_lagrangian_l3 = -0.000261
@inline augmented_lagrangian_constraint(x, h, k) = 2 * x[k+1] + h^2 * ((x[k+1] + h * (k+1) + 1)^3) / 2 - x[k] - x[k+2]
# T-aware overload: the trailing /2 produces a Float64 inv(2) in the derivative
# even when h is Float32 — wrap the divisor in T(2) so the kernel stays in T.
@inline augmented_lagrangian_constraint(x, h, k, ::Type{T}) where {T} = 2 * x[k+1] + h^2 * ((x[k+1] + h * (k+1) + 1)^3) / T(2) - x[k] - x[k+2]
@inline augmented_lagrangian_objective(x, l1, l2, l3, i) = exp(x[5i] * x[5i-1] * x[5i-2] * x[5i-3] * x[5i-4]) +
    10 * (x[5i]^2 + x[5i-1]^2 + x[5i-2]^2 + x[5i-3]^2 + x[5i-4]^2 - 10 - l1)^2 +
    (x[5i-3] * x[5i-2] - 5 * x[5i-1] * x[5i] - l2)^2 +
    (x[5i-4]^3 + x[5i-3]^3 + 1 - l3)^2
