# Animations

[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://jkrumbiegel.github.io/Animations.jl/stable)
[![](https://img.shields.io/badge/docs-dev-blue.svg)](https://jkrumbiegel.github.io/Animations.jl/dev)
[![Build Status](https://travis-ci.com/jkrumbiegel/Animations.jl.svg?branch=master)](https://travis-ci.com/jkrumbiegel/Animations.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/jkrumbiegel/Animations.jl?svg=true)](https://ci.appveyor.com/project/jkrumbiegel/Animations-jl)
[![Codecov](https://codecov.io/gh/jkrumbiegel/Animations.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/jkrumbiegel/Animations.jl)

Animations.jl offers an easy way to set up simple animations where multiple keyframes
are interpolated between in sequence. You can choose different easing functions or
create your own. Keyframe values can be anything that can be linearly interpolated, you
can also add your own methods for special types. An easing can have repetitions and
delays, so that looping animations are simpler to create.

Check out the [documentation here](https://jkrumbiegel.github.io/Animations.jl/dev)!


```julia
x = Animation([0, duration], [1.0, 0.0], polyout(2; n=8, yoyo=true))
y = Animation([0, duration], [0.0, 1.0], linear(n=2, yoyo=true))

color = Animation(
    [0, 0.25, 0.5, 0.75] .* duration,
    [RGB(0.251, 0.388, 0.847), RGB(0.22, 0.596, 0.149), RGB(0.584, 0.345, 0.698), RGB(0.796, 0.235, 0.2)],
    noease())
```

<p align="center">
    <a href="https://github.com/jkrumbiegel/Animations.jl/blob/master/misc/example.jl">
        <img src="https://raw.githubusercontent.com/jkrumbiegel/Animations.jl/master/misc/example.gif">
    </a>
</p>

<p align="center">
    <a href="https://github.com/jkrumbiegel/Animations.jl/blob/master/misc/example_array.jl">
        <img src="https://raw.githubusercontent.com/jkrumbiegel/Animations.jl/master/misc/example_array.gif">
    </a>
</p>
