# Animations

[![Build Status](https://travis-ci.com/jkrumbiegel/Animations.jl.svg?branch=master)](https://travis-ci.com/jkrumbiegel/Animations.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/jkrumbiegel/Animations.jl?svg=true)](https://ci.appveyor.com/project/jkrumbiegel/Animations-jl)
[![Codecov](https://codecov.io/gh/jkrumbiegel/Animations.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jkrumbiegel/Animations.jl)

Animations.jl offers an easy way to set up simple animations where multiple keyframes
are interpolated between in sequence. You can choose different easing functions or
create your own. Keyframe values can be anything that can be linearly interpolated, you
can also add your own methods for special types. An easing can have repetitions and
delays, so that looping animations are simpler to create.

<p align="center">
    <img src="https://raw.githubusercontent.com/jkrumbiegel/Animations.jl/master/misc/example.gif">
</p>

### Syntax examples

Creating an animation from 0 at t = 0, to 10 at t = 2, and then 20 at t = 3,
with a sine in / out easing that yoyos 3 times and then a linear easing:

```julia
anim = Animation(
    0, 0,
    sineio(n=3, yoyo=true),
    2, 10,
    linear(),
    3, 20
)
```

Another way to write this is with vectors for timestamps and values, although the
first version can be easier to understand with multiple timestamps:

```julia
anim = Animation(
    [0, 2, 3],
    [0, 10, 20],
    [sineio(n=3, yoyo=true), linear()],
)
```

You can get an animation's value for a specific t by calling it:

```julia
val_1 = anim(t)
```

### Colors and special types

Using Colors is enabled already, but you can add other custom types that can be interpolated:

```julia
coloranim = Animation(
    0, RGB(1, 0, 0),
    sineio(),
    1, RGB(0, 1, 0),
    polyin(2),
    2, RGB(0, 0, 1)
)
```

For your own type T, if the generic `(value2 - value1) * fraction + value1` doesn't work,
just add a method `linear_interpolate(fraction::Real, value1::T, value2::T) where T`.

### Arrays

Interpolation also works easily with arrays of values:

```julia
Animation(
    0, rand(25),
    sineio(n=2, yoyo=true, prewait=0.3),
    2, rand(25)
)
```

Here's an example using arrays, in this case a grid of points:

<p align="center">
    <img src="https://raw.githubusercontent.com/jkrumbiegel/Animations.jl/master/misc/example_array.gif">
</p>

### Relative timestamps

If you're tweaking the length of parts of an animation, you can use `rel()` for
a timestamp relative to the previous one, like so:

```julia
Animation(
    0,        1,
    rel(1),   2,
    rel(3),   3,
    rel(0.2), 0,
    rel(0.4), 1
)
```

This way it's easier to adjust one duration without having to change all following ones.

### FiniteLengthAnimation

Animations, Loops and Sequences are subtypes of FiniteLengthAnimation, which are
required as the content for (finite) Loops and Sequences

### Loops

You can turn a FiniteLengthAnimation into a loop like this:

```julia
a = Animation(
    0,   1,
    sineio(),
    0.5, 2,
    polyin(3),
    1,   1
)

start = 0
gap = 1
repetitions = 3
l = Loop(a, start, gap, repetitions)
```

### Sequences

You can string together FiniteLengthAnimations into sequences like this:

```julia
anim1 = Animation(
    0,   1,
    sineio(),
    0.5, 2,
    polyin(3),
    1,   1
)

anim2 = Animation(
    0,   1,
    saccadic(2),
    0.5, 5,
    expout(3),
    1,   1
)

loop = Loop(anim2, 0, 0.5, 3)

start = 0
gap = 1
sequence = Sequence([anim1, loop], start, gap)
```


### Easing functions

Here are some examples of standard easing functions:

<p align="center">
  <a href="https://github.com/jkrumbiegel/Animations.jl/blob/master/misc/easingplots.jl">
    <img src="https://raw.githubusercontent.com/jkrumbiegel/Animations.jl/master/misc/easingplots.svg?sanitize=true">
  </a>
</p>
