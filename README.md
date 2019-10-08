# Animations

[![Build Status](https://travis-ci.com/jkrumbiegel/Animations.jl.svg?branch=master)](https://travis-ci.com/jkrumbiegel/Animations.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/jkrumbiegel/Animations.jl?svg=true)](https://ci.appveyor.com/project/jkrumbiegel/Animations-jl)
[![Codecov](https://codecov.io/gh/jkrumbiegel/Animations.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jkrumbiegel/Animations.jl)

Animations.jl offers an easy way to set up simple animations where multiple keyframes
are interpolated between in sequence. You can choose different easing functions or
create your own. Keyframe values can be anything that can be linearly interpolated, you
can also add your own methods for special types. An easing can have repetitions and
delays, so that looping animations are simpler to create.

### Syntax examples

Creating an animation from 0 at t = 0, to 10 at t = 2, with a sine in / out easing that loops back and forth once:

```
anim = Animation(
    0, 0,
    sineio(n=2, yoyo=true),
    2, 10
)
```

You can get an animation's value for a specific t by calling it:

```
val_1 = anim(t)
```
