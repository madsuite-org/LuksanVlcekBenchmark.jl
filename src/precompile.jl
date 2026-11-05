# An ExaModel's type encodes its expressions, so every problem compiles its own
# callbacks on first use.  The `precompile` preference stores that code in the
# package images.  It is read at compile time, so changing it invalidates them;
# `false`, the default, compiles nothing.
const PRECOMPILE = @load_preference("precompile", false)

"""
    set_precompile(flag::Bool)

Turn on or off compiling every ExaModels problem into the package images, so
that they build and evaluate in a new Julia session without compiling.  The
default is `false`.

The setting is stored in the active project's `LocalPreferences.toml` and takes
effect in the next Julia session, which rebuilds the images.
"""
function set_precompile(flag::Bool)
    @set_preferences!("precompile" => flag)
    @info "Restart Julia for this to take effect."
    return flag
end

"""
    _precompile_workload(backend; T = nothing)

Build every ExaModels problem on `backend` and call the callbacks a solver uses.
`T` is passed only when given (Metal needs `Float32`).  A problem that throws is
logged and skipped, so that one failure does not discard the image.  The method
is in the ExaModels extension.
"""
function _precompile_workload end
