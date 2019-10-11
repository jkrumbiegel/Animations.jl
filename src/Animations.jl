module Animations

import Observables
import Colors

# easings.jl
export Easing,
    eased,
    expin,
    expout,
    funcease,
    linear,
    mixed,
    multiplied,
    noease,
    opposite,
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

# loop.jl
export Loop

include("easings.jl")
include("keyframes.jl")
include("animation.jl")
include("interpolation.jl")
include("loop.jl")

end
