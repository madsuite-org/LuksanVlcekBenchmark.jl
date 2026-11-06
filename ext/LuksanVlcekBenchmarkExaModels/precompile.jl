# Model types do not depend on the size, so one small size covers the CPU.  A
# device also needs a large one: above one thread block, building and evaluating
# a model launches kernels that a small size does not.
const PRECOMPILE_SIZES = (100, 100_000)

# Calls made through `invokelatest`, as from the top level, so that each is
# compiled as a standalone method rather than only inlined into the workload.
_call(f, args...; kw...) = Base.invokelatest(f, args...; kw...)

function LV._precompile_workload(backend; T = nothing)
    kw = backend === nothing ? (;) : (; backend)
    kw = T === nothing ? kw : (; kw..., T)
    sizes = backend === nothing ? PRECOMPILE_SIZES[1:1] : PRECOMPILE_SIZES
    for name in LV.NAMES
        endswith(string(name), "_model") || continue
        try
            model = getfield(LV, name)
            for N in sizes
                EM.precompile_callbacks(_call(model, LV.ExaModelsBackend(), N; kw...))
            end
        catch err
            @warn "skipping $name in the package image" exception = err
        end
    end
    return nothing
end

PrecompileTools.@compile_workload begin
    if LV.PRECOMPILE
        LV._precompile_workload(nothing)
    end
end
