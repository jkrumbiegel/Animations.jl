module Animations

import Observables
import Colors

# easings.jl
export Easing,
    EasingType,
    expin,
    ExpInEasing,
    EasedEasing,
    LinearEasing,
    linease,
    MixedEasing,
    MultipliedEasing,
    noease,
    NoEasing,
    polyin,
    PolyInEasing,
    polyout,
    PolyOutEasing,
    stepease,
    saccadic,
    SaccadicEasing,
    sineio,
    SineIOEasing,
    StepEasing

# keyframes.jl
export Keyframe

# animation.jl
export Animation,
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
