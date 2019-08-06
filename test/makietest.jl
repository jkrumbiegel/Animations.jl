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
        Easing(easing=LinearEasing(), ntimes=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[1. 0.], [1. 1.]],
        Easing(easing=NoEasing(), ntimes=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[2. 0.], [2. 1.]],
        Easing(easing=StepEasing(), ntimes=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[3. 0.], [3. 1.]],
        Easing(easing=SineIOEasing(), ntimes=1, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[4. 0.], [4. 1.]],
        Easing(easing=SineIOEasing(), ntimes=3, yoyo=false, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[5. 0.], [5. 1.]],
        Easing(easing=SineIOEasing(), ntimes=3, yoyo=false, prewait=0.2, postwait=0.2)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[6. 0.], [6. 1.]],
        Easing(easing=SineIOEasing(), ntimes=3, yoyo=true, prewait=0.0, postwait=0.0)
    ))

    push!(animations, Animations.Animation(
        [0, 3],
        [[7. 0.], [7. 1.]],
        Easing(easing=SineIOEasing(), ntimes=3, yoyo=true, prewait=0.2, postwait=0.2)
    ))

    color_animation = Animations.Animation(
        [0, 3],
        [LCHab(70, 70, 0), LCHab(70, 70, 360)],
        Easing(easing=LinearEasing())
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

    e1 = Easing(easing=LinearEasing(), ntimes=11, yoyo=true, prewait=0.0, postwait=0.0)
    e2 = Easing(easing=SineIOEasing())

    a = Animations.Animation(
        [0, 3],
        [[0. 0.], [0. 1.]],
        Easing(easing=MixedEasing(e1, e2, 0.5))
    )

    scene = Scene(resolution=(600, 600))
    scatter!(scene, a.obs, markersize=0.2)

    record(scene, "test2.gif", 0:1/25:3; framerate=25) do t
        Animations.update!(a, t)
    end

end

test2()

function test3()

    e1 = Easing(easing=LinearEasing(), ntimes=5, yoyo=true, prewait=0.0, postwait=0.0)
    e2 = Easing(easing=LinearEasing())

    a = Animations.Animation(
        [0, 3],
        [[0. 0.], [0. 1.]],
        Easing(easing=MultipliedEasing(e1, e2))
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
        Easing(easing=LinearEasing())
    )

    ay = Animations.Animation(
        [0, 3],
        [0.0, 1.0],
        Easing(easing=SineIOEasing(), ntimes=5, yoyo=true)
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
        Easing(easing=CompressedExpEasing(0.1))
    ))

    push!(animations, Animations.Animation(
        [0, 1],
        [[1. 0.], [1. 1.]],
        Easing(easing=CompressedExpEasing(1.0))
    ))

    push!(animations, Animations.Animation(
        [0, 1],
        [[2. 0.], [2. 1.]],
        Easing(easing=CompressedExpEasing(10.0))
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

    e1 = Easing(easing=PolyInEasing(4.0), ntimes=1, yoyo=false, prewait=0.0, postwait=0.0)
    e2 = Easing(easing=SineIOEasing(), ntimes=3, yoyo=true)

    a = Animations.Animation(
        [0, 2],
        [[0. 0.], [0. 1.]],
        Easing(easing=MultipliedEasing(e1, e2))
    )

    scene = Scene(resolution=(600, 600))
    scatter!(scene, a.obs, markersize=0.2)

    record(scene, "test6.gif", -0.5:1/25:2.5; framerate=25) do t
        Animations.update!(a, t)
    end

end

test6()
