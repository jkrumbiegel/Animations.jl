using Revise
using Makie
using Animations

function test()
    a = Animations.Animation(
        @timestamps(0, :2),
        [[1. 1], [2. 2]],
        Easing(easing=SineIOEasing(), ntimes=9, yoyo=true)
    )

    println(a.obs)

    pos = lift(p -> p, a.obs)

    scene = Scene(resolution=(500, 500))
    scat = scatter!(scene, pos)[end]
    scene

    record(scene, "test.mp4", 0:1/60:2) do t
        Animations.update!(a, t)
    end
    nothing
end

test()
