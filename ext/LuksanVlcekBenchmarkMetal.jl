# Precompiles model building and evaluation on Apple GPUs (Metal) when the `precompile`
# preference is on (see src/precompile.jl).  Needs a functional device at
# precompile time.  `ExaModels` and `KernelAbstractions` are triggers, and are
# imported here because an unimported trigger is not loaded while this extension
# precompiles: ExaModels' backend extensions and this package's ExaModels
# extension, which has the workload, load only once they are.  Julia 1.11 is
# excluded: there the workload leaves an image that fails to load or gains nothing.
module LuksanVlcekBenchmarkMetal

import ExaModels
import KernelAbstractions
import LuksanVlcekBenchmark
import Metal
import PrecompileTools

PrecompileTools.@compile_workload begin
    if VERSION >= v"1.12" && LuksanVlcekBenchmark.PRECOMPILE && Metal.functional()
        LuksanVlcekBenchmark._precompile_workload(Metal.MetalBackend(); T = Float32)
    end
end

end
