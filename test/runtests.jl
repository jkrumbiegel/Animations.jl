using Test
using Animations
using Observables

@testset "keyframes" begin

    kf1 = Keyframe(1, 5.0)
    kf2 = Keyframe(3, 10.0)
    kf3 = Keyframe(5, 0.0)

    animation = Animation(
        [kf1, kf2, kf3],
        Easing[SineEasing(), SineEasing()]
    )

    on(animation) do x
        println(x)
    end
    update!.(animation, [0, 1, 2, 3, 4, 5, 6])
end

@testset "vector interpolate" begin

    kf1 = Keyframe(0, [0.0, 0.0, 0.0])
    kf2 = Keyframe(1, [1.0, 2.0, 3.0])

    animation = Animation(
        [kf1, kf2],
        Easing[SineEasing()]
    )

    on(animation) do x
        println(x)
    end
    update!.(animation, [0, 0.25, 0.5, 0.75, 1])

end
