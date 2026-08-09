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

const NAMES = filter(names(LuksanVlcekBenchmark; all = true)) do x
    str = string(x)
    endswith(str, "model") && !startswith(str, "#")
end

const CORE_NAMES = filter(names(LuksanVlcekBenchmark; all = true)) do x
    str = string(x)
    endswith(str, "core") && !startswith(str, "#")
end

for name in CORE_NAMES
    @eval export $name
end

for name in NAMES
    @eval export $name
end

export LV

end # module LuksanVlcekBenchmark
