# LuksanVleckBenchmark

[![Build Status](https://github.com/jerryfung110/LuksanVleckBenchmark.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/jerryfung110/LuksanVleckBenchmark.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/jerryfung110/LuksanVleckBenchmark.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jerryfung110/LuksanVleckBenchmark.jl)
[![Coverage](https://coveralls.io/repos/github/jerryfung110/LuksanVleckBenchmark.jl/badge.svg?branch=master)](https://coveralls.io/github/jerryfung110/LuksanVleckBenchmark.jl?branch=master)

## Precompiling models

Each ExaModels model compiles its own code the first time it is built and
evaluated. To store that code in the package images:

```julia
using LuksanVlcekBenchmark
set_precompile(true)
```

Restart Julia. The next `using` rebuilds the images, which takes longer and
makes them larger, and the models then start without compiling. The default is
`false`, which compiles nothing; `set_precompile(false)` turns it off again. The
setting is stored in the active project's `LocalPreferences.toml`.

The CPU code is compiled when ExaModels is loaded. A GPU backend (CUDA, AMDGPU,
oneAPI, or Metal in `Float32`) has its own workload, which runs when that package
is loaded and a device works at precompile time, on Julia 1.12 or newer. oneAPI's
never does, because oneAPI.jl reports no working device during precompilation.
