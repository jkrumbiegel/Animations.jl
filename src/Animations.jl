module Animations

import Observables
import Colors

# easings.jl
export Easing,
    expin,
    EasedEasing,
    funcease,
    FuncEasing,
    linease,
    MixedEasing,
    MultipliedEasing,
    noease,
    polyin,
    polyout,
    saccadic,
    sineio,
    stepease

# keyframes.jl
export Keyframe

# animation.jl
export Animation,
    at,
    easings,
    keyframes,
    keyvalues,
    observable,
    rel,
    timestamps,
    update!,
    value

include("easings.jl")
include("keyframes.jl")
include("animation.jl")
include("interpolation.jl")

end
