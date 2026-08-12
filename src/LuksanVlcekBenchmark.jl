module LuksanVlcekBenchmark

const LV = LuksanVlcekBenchmark

abstract type AbstractModelerBackend end
struct JuMPBackend <: AbstractModelerBackend end
struct ExaModelsBackend <: AbstractModelerBackend end

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

# Every problem's public surface.  `*_model` is the model itself; `*_recipe` is
# its structure with the size left open and `*_args` the values that close it,
# for the backends that can separate the two.  A backend that cannot simply does
# not define the latter, and is exported exactly as it was.
const NAMES = filter(names(LuksanVlcekBenchmark; all = true)) do x
    str = string(x)
    any(endswith(str, sfx) for sfx in ("model", "recipe", "args")) && !startswith(str, "#")
end

for name in NAMES
    @eval export $name
end

export LV

end # module LuksanVlcekBenchmark
