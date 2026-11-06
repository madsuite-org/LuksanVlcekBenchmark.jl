# Loading KernelAbstractions adds methods that invalidate the CPU code in the ExaModels
# extension's image (`Adapt.adapt_storage` from its POCL backend, `convert(::Type{String}, _)`
# from LLVM). This image is loaded after those methods, so what it stores stays valid.
module LuksanVlcekBenchmarkKernelAbstractions

import ExaModels
import KernelAbstractions
import LuksanVlcekBenchmark
import PrecompileTools

PrecompileTools.@compile_workload begin
    if LuksanVlcekBenchmark.PRECOMPILE
        LuksanVlcekBenchmark._precompile_workload(nothing)
    end
end

end
