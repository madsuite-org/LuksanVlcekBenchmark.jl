module LuksanVlcekBenchmarkExaModelsCompiler

# Compiling every Luksan-Vlcek problem into one shared library.  The problems
# are eighteen recipes over a single open size, so `compile_all` here is that
# list plus the size to close them at; everything else -- where the library
# goes, which models to keep, whether to bundle a runtime -- is
# ExaModelsCompiler's contract and is forwarded untouched.
#
# This lives in an extension so the package itself never depends on the
# compiler: a benchmark set is a modelling package, and a compiler toolchain is
# not something you should acquire by loading one.

import LuksanVlcekBenchmark as LV
import ExaModelsCompiler
using ExaModelsCompiler: compile_library, select

# Derived from the package's own surface rather than hand-listed, so a problem
# added to `src/` is compiled without editing this file -- the list and the
# package cannot drift apart if there is only one of them.
_problems() = sort!([
    Symbol(chopsuffix(string(n), "_recipe")) for n in LV.NAMES if endswith(string(n), "_recipe")
])

function ExaModelsCompiler.compile_all(
    ::Val{LV};
    path = "@lv",
    sizes = 1000,
    T = Float64,
    only = nothing,
    exclude = (),
    kwargs...,
)
    b = LV.ExaModelsBackend()
    models = map(_problems()) do name
        recipe = getfield(LV, Symbol(name, :_recipe))
        args = getfield(LV, Symbol(name, :_args))
        name => (recipe(b; T = T), args(b, sizes)...)
    end
    return compile_library(path, select(models; only, exclude)...; kwargs...)
end

end # module
