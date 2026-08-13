module LuksanVlcekBenchmarkExaModels

import ExaModels
import LuksanVlcekBenchmark
const LV = LuksanVlcekBenchmark
const EM = ExaModels

# ── Deferred callables in recipes ─────────────────────────────────────────────
#
# Every function a recipe defers — start generators, index-set builders, data
# tables — must be NAMED and owned by THIS PACKAGE: not an anonymous closure,
# not an extension-owned function, not anything in `Main`.  Two independent
# mechanisms require it.  The serialized core carries the function's TYPE,
# which another process can resolve only through the owning package's `PkgId`;
# and an AOT-compiled library calls argument functions by NAME, which only a
# package import makes reachable.  `Base.Fix2` over such a function is fine —
# the wrapper's type parameters stay named.

include("rosenrock.jl")
include("wood.jl")
include("chained_powell.jl")
include("cragg_levy.jl")
include("broyden_tridiagonal.jl")
include("broyden_banded.jl")
include("trigo_tridiagonal.jl")
include("augmented_lagrangian.jl")
include("modified_brown.jl")
include("generalized_brown.jl")
include("Chained_HS46.jl")
include("Chained_HS47.jl")
include("Chained_HS48.jl")
include("Chained_HS49.jl")
include("Chained_HS50.jl")
include("Chained_HS51.jl")
include("Chained_HS52.jl")
include("Chained_HS53.jl")

end
