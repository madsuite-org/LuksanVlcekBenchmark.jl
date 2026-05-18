# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.5
# Extra objective terms are introduced to handle x[0] == 0 and x[n+1] == 0

function broyden_tridiagonal_model end
@inline broyden_tridiagonal_constraint(x, k) = 8 * x[k+2] * (x[k+2]^2 - x[k+1]) - 2 * (1 - x[k+2]) +
    4 * (x[k+2] - x[k+3]^2) + x[k+1]^2 - x[k] + x[k+3] - x[k+4]^2
@inline broyden_tridiagonal_objective(x, i) = abs((3 - 2 * x[i]) * x[i] - x[i-1] - x[i+1] + 1)^7 / 3
@inline broyden_tridiagonal_objective_boundary(x, N) = abs((3 - 2 * x[1]) * x[1] - x[2] + 1)^7 / 3 + abs((3 - 2 * x[N]) * x[N] - x[N-1] + 1)^7 / 3
# T-aware overloads: avoid Float64 inv(3) in the derivative when T is Float32.
# Needed for fp32 GPU backends (Metal, oneAPI) that reject double-precision ops in kernels.
@inline broyden_tridiagonal_objective(x, i, ::Type{T}) where {T} = abs((3 - 2 * x[i]) * x[i] - x[i-1] - x[i+1] + 1)^7 / T(3)
@inline broyden_tridiagonal_objective_boundary(x, N, ::Type{T}) where {T} = abs((3 - 2 * x[1]) * x[1] - x[2] + 1)^7 / T(3) + abs((3 - 2 * x[N]) * x[N] - x[N-1] + 1)^7 / T(3)
