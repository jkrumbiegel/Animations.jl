using Pkg
pkg"activate ."
using Revise
using Makie
using Animations
using Printf
using Colors

Animations.linear_interpolate(fraction::Real, c1::Color, c2::Color) = weighted_color_mean(1 - fraction, c1, c2)

function test()

    animations = []

    push!(animations, Animations.Animation(
        [0, 3],
        [[0. 0.], [0. 1.]],
        Easing(LinearEasing(), n=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[1. 0.], [1. 1.]],
        Easing(NoEasing(), n=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[2. 0.], [2. 1.]],
        Easing(StepEasing(), n=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[3. 0.], [3. 1.]],
        Easing(SineIOEasing(), n=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[4. 0.], [4. 1.]],
        Easing(SineIOEasing(), n=3, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[5. 0.], [5. 1.]],
        Easing(SineIOEasing(), n=3, yoyo=false, prewait=0.2, postwait=0.2)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[6. 0.], [6. 1.]],
        Easing(SineIOEasing(), n=3, yoyo=true, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[7. 0.], [7. 1.]],
        Easing(SineIOEasing(), n=3, yoyo=true, prewait=0.2, postwait=0.2)
    ))

    color_animation = Animations.Animation(
        [0, 3],
        [LCHab(70, 70, 0), LCHab(70, 70, 360)],
        Easing(LinearEasing())
    )

    text_animation = Animations.Animation(
        [0, 1, 2, 3],
        ["stuff without", "interpolation works", "also with", "discrete steps"],
        Easing()
    )

    width = length(animations) - 1

    scene = Scene(resolution=(600, 600))
    for a in animations
        scatter!(scene, a.obs, markersize=0.2, color=color_animation.obs)
    end

    translate!(lines!(scene, [0, width], [0, 0])[end], (0, 0, -1))
    translate!(lines!(scene, [0, width], [1, 1])[end], (0, 0, -1))

    timestamp = Node("0")
    text!(scene, timestamp, position=Point2f0(width / 2, 1.2), align = (:center,  :center), textsize = 0.4)

    text!(scene, text_animation.obs, position=Point2f0(width / 2, 0.5), align = (:center,  :center), textsize = 0.4)

    record(scene, "test.gif", -1:1/25:4; framerate=25) do t
        Animations.update!.(animations, t)
        Animations.update!(color_animation, t)
        Animations.update!(text_animation, t)
        timestamp[] = @sprintf "t = %.2f" t
    end
    nothing
end

test()


function test2()

    e1 = Easing(LinearEasing(), n=11, yoyo=true, prewait=0.0, postwait=0.0)
    e2 = Easing(SineIOEasing())

    a = Animations.Animation(
        [0, 3],
        [[0. 0.], [0. 1.]],
        Easing(MixedEasing(e1, e2, 0.5))
    )

    scene = Scene(resolution=(600, 600))
    scatter!(scene, a.obs, markersize=0.2)

    record(scene, "test2.gif", 0:1/25:3; framerate=25) do t
        Animations.update!(a, t)
    end

end

test2()

function test3()

    e1 = Easing(LinearEasing(), n=5, yoyo=true, prewait=0.0, postwait=0.0)
    e2 = Easing(LinearEasing())

    a = Animations.Animation(
        [0, 3],
        [[0. 0.], [0. 1.]],
        Easing(MultipliedEasing(e1, e2))
    )

    scene = Scene(resolution=(600, 600))
    scatter!(scene, a.obs, markersize=0.2)

    record(scene, "test3.gif", 0:1/25:3; framerate=25) do t
        Animations.update!(a, t)
    end

end

test3()

function test4()

    ax = Animations.Animation(
        [0, 3],
        [0.0, 1.0],
        Easing(LinearEasing())
    )

    ay = Animations.Animation(
        [0, 3],
        [0.0, 1.0],
        Easing(SineIOEasing(), n=5, yoyo=true)
    )

    p = lift((x, y) -> [x y], ax.obs, ay.obs)

    scene = Scene(resolution=(600, 600))
    scatter!(scene, p, markersize=0.2)

    record(scene, "test4.gif", 0:1/25:3; framerate=25) do t
        Animations.update!(ax, t)
        Animations.update!(ay, t)
    end

end

test4()


function test5()

    animations = []

    push!(animations, Animations.Animation(
        [0, 1],
        [[0. 0.], [0. 1.]],
        Easing(CompressedExpEasing(0.1))
    ))

    push!(animations, Animations.Animation(
        [0, 1],
        [[1. 0.], [1. 1.]],
        Easing(CompressedExpEasing(1.0))
    ))

    push!(animations, Animations.Animation(
        [0, 1],
        [[2. 0.], [2. 1.]],
        Easing(CompressedExpEasing(10.0))
    ))

    width = length(animations) - 1

    scene = Scene(resolution=(600, 600))
    for a in animations
        scatter!(scene, a.obs, markersize=0.2)
    end

    translate!(lines!(scene, [0, width], [0, 0])[end], (0, 0, -1))
    translate!(lines!(scene, [0, width], [1, 1])[end], (0, 0, -1))

    record(scene, "test.gif", -1:1/25:2; framerate=25) do t
        Animations.update!.(animations, t)
    end
    nothing
end

test5()

function test6()

    e1 = Easing(PolyInEasing(4.0), n=1, yoyo=false, prewait=0.0, postwait=0.0)
    e2 = Easing(SineIOEasing(), n=3, yoyo=true)

    a = Animations.Animation(
        [0, 2],
        [[0. 0.], [0. 1.]],
        Easing(MultipliedEasing(e1, e2))
    )

    scene = Scene(resolution=(600, 600))
    scatter!(scene, a.obs, markersize=0.2)

    record(scene, "test6.gif", -0.5:1/25:2.5; framerate=25) do t
        Animations.update!(a, t)
    end

end

test6()

function test7()

    animations = Animations.Animation.(
        Ref([0, 0.5]),
        [[[i 0.], [i 1.]] for i in 1:5],
        (Easing(ExpInEasing(i)) for i in [0.1, 0.5, 1.1, 2, 5])
    )

    scene = Scene(resolution=(600, 600))
    scatter!.(scene, (a.obs for a in animations), markersize=0.2)

    record(scene, "test7.gif", -0.5:1/25:1.5; framerate=25) do t
        Animations.update!.(animations, t)
    end

end

test7()


function test8()

    animation = Animations.Animation(
        [0, 1, 2, 3],
        Point2{Float64}[(0, 0), (1, 0), (0.5, 0.666), (0, 0)],
        Easing(PolyOutEasing(2), postwait=0.33)
    )

    scene = Scene(resolution=(600, 600))
    scatter!(scene, lift(x -> [x], animation.obs), markersize=0.2)

    record(scene, "test8.gif", 0:1/25:3; framerate=25) do t
        Animations.update!(animation, t)
    end

end

test8()
