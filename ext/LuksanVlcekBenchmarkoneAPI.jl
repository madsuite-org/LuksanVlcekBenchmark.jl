# Precompiles model building and evaluation on Intel GPUs (oneAPI) when the `precompile`
# preference is on (see src/precompile.jl).  Needs a functional device at
# precompile time.  `ExaModels` and `KernelAbstractions` are triggers, and are
# imported here because an unimported trigger is not loaded while this extension
# precompiles: ExaModels' backend extensions and this package's ExaModels
# extension, which has the workload, load only once they are.  `oneAPI.functional()`
# is false during precompilation, so the workload does not run yet.
module LuksanVlcekBenchmarkoneAPI

import ExaModels
import KernelAbstractions
import LuksanVlcekBenchmark
import oneAPI
import PrecompileTools

PrecompileTools.@compile_workload begin
    if LuksanVlcekBenchmark.PRECOMPILE && oneAPI.functional()
        LuksanVlcekBenchmark._precompile_workload(oneAPI.oneAPIBackend())
    end
end

end
