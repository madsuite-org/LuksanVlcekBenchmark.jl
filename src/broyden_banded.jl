# The following question was adopted from Lukšan, L., & Vlček, J. (1999). Sparse and Partially Separable Test Problems for Unconstrained and Equality Constrained Optimization.
# Institute of Computer Science, Academy of Sciences of the Czech Republic. Technical report No. 767 Problem 5.6
# y variable does not exist in the original problem; it is introduced to represent the summation in the objective.

function broyden_banded_model end
@inline broyden_banded_xi(x, i) = x[i] * (1 + x[i])
@inline broyden_banded_kconstraint(x, k) = 4 * x[2k] - (x[2k-1] - x[2k+1]) * exp(x[2k-1] - x[2k] - x[2k+1]) - 3
@inline broyden_banded_yconstraint(y, x, i) = y[i] - x[i-5] * (1 + x[i-5]) - x[i-4] * (1 + x[i-4]) -
    x[i-3] * (1 + x[i-3]) - x[i-2] * (1 + x[i-2]) -
    x[i-1] * (1 + x[i-1]) - x[i] * (1 + x[i]) - x[i+1] * (1 + x[i+1])
@inline broyden_banded_ylast(y, x, n) = y[n] - x[n-5] * (1 + x[n-5]) - x[n-4] * (1 + x[n-4]) -
    x[n-3] * (1 + x[n-3]) - x[n-2] * (1 + x[n-2]) - x[n-1] * (1 + x[n-1]) - x[n] * (1 + x[n])
@inline broyden_banded_objective(x, y, i) = abs((2 + 5 * x[i]^2) * x[i] + 1 + y[i])^7 / 3
# T-aware overload: avoids Float64 inv(3) in the derivative when T is Float32.
# Needed for fp32 GPU backends (Metal, oneAPI) that reject double-precision ops in kernels.
@inline broyden_banded_objective(x, y, i, ::Type{T}) where {T} = abs((2 + 5 * x[i]^2) * x[i] + 1 + y[i])^7 / T(3)
