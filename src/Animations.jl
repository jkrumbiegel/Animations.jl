module Animations

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
    polyio,
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
    rel,
    timestamps

# loop.jl
export Loop

# sequence.jl
export Sequence

# animate_async.jl
export animate_async, stop

include("easings.jl")
include("keyframes.jl")
include("animation.jl")
include("interpolation.jl")
include("loop.jl")
include("sequence.jl")
include("animate_async.jl")

end
