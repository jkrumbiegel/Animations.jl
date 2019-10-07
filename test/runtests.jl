using Test
using Animations
using Observables
using Colors: Color, RGB, weighted_color_mean

@testset "keyframes" begin

    kf1 = Keyframe(1, 5.0)
    kf2 = Keyframe(3, 10.0)
    kf3 = Keyframe(6, 0.0)

    animation = Animation(
        [kf1, kf2, kf3],
        [Easing(SineIOEasing()), Easing(LinearEasing())]
    )

    @test timestamps(animation) == [1, 3, 6]
    @test keyvalues(animation) == [5.0, 10.0, 0.0]
end

@testset "animation creation" begin
    anim = Animation(
        1, 5,
        2, 10,
        saccadic(2),
        3, 20,
        sineio(),
        4, 100
    )

    @test keyvalues(anim) == [5, 10, 20, 100]
    @test timestamps(anim) == [1, 2, 3, 4]
    @test easings(anim) == [linease(), saccadic(2), sineio()]
end

@testset "animation creation defaulteasing" begin
    e = polyin(3; n=3, yoyo=true)
    anim = Animation(
        1, 5,
        2, 10,
        saccadic(2),
        3, 20,
        sineio(),
        4, 100;
        defaulteasing=e
    )

    @test keyvalues(anim) == [5, 10, 20, 100]
    @test timestamps(anim) == [1, 2, 3, 4]
    @test easings(anim) == [e, saccadic(2), sineio()]
end

@testset "temporally changed animations" begin
    anim = Animation(
        1, 10,
        2, 20,
        3, 30,
    )

    anim_later = anim + 1
    @test timestamps(anim_later) == [2, 3, 4]
    anim_earlier = anim - 1
    @test timestamps(anim_earlier) == [0, 1, 2]
    anim_longer = anim * 2
    @test timestamps(anim_longer) == [2, 4, 6]
    anim_shorter = anim / 2
    @test timestamps(anim_shorter) == [0.5, 1, 1.5]
end

@testset "vector interpolate" begin

    kf1 = Keyframe(0, [0.0, 0.0, 0.0])
    kf2 = Keyframe(1, [1.0, 2.0, 3.0])

    animation = Animation(
        [kf1, kf2],
        Easing(SineIOEasing())
    )

    @test animation(0) == [0.0, 0.0, 0.0]
    @test animation(0.5) == [0.5, 1.0, 1.5]
    @test animation(1) == [1.0, 2.0, 3.0]
end

@testset "color interpolate" begin

    c1 = RGB(0.0, 0, 0)
    c2 = RGB(1, 0.5, 0.3)
    kf1 = Keyframe(0, c1)
    kf2 = Keyframe(1, c2)

    animation = Animation(
        [kf1, kf2],
        Easing(SineIOEasing())
    )

    @test animation(0) == c1
    @test animation(0.5) == Animations.Colors.weighted_color_mean(0.5, c1, c2)
    @test animation(1) == c2
end

@testset "string steps" begin

    kf1 = Keyframe(0, "first")
    kf2 = Keyframe(1, "second")
    kf3 = Keyframe(2, "third")

    animation = Animation(
        [kf1, kf2, kf3],
        Easing(NoEasing())
    )

    @test animation(0) == "first"
    @test animation(0.5) == "first"
    @test animation(1) == "second"
    @test animation(1.5) == "second"
    @test animation(2) == "third"
end

@testset "yoyo repeat" begin

    animation = Animation(
        [0, 3],
        [0.0, 1.0],
        Easing(LinearEasing(), n=3, yoyo=true)
    )

    results = [0.0, 0.25, 0.5, 0.75, 1.0, 0.75, 0.5, 0.25, 0.0, 0.25, 0.5, 0.75, 1.0]
    @test animation.(collect(0:0.25:3)) == results

end

@testset "even yoyo" begin
    animation = Animation(
        [1, 3],
        [0.0, 1.0],
        linease(n=2, yoyo=true)
    )

    @test animation.(0:4) == [0, 0, 1, 0, 0]
end
