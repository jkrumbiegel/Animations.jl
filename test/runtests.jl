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

    values = evaluate.(animation, [0, 1, 2, 3, 4, 5, 6])
    println(values)
end

@testset "animator" begin

    a = Animator()

    obs = Observable(0.0)

    on(obs) do x
        println("x changed to $x")
    end

    kf1 = Keyframe(1, 5.0)
    kf2 = Keyframe(3, 10.0)
    kf3 = Keyframe(5, 0.0)

    animation = Animation(
        [kf1, kf2, kf3],
        Easing[SineEasing(), SineEasing()]
    )

    add!(a, obs, animation)

    update.(a, [0, 1, 2, 3, 4, 5, 6])

end
