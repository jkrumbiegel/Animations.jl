using Test
using Animations
using Colors

@testset "keyframes" begin

    kf1 = Keyframe(1, 5.0)
    kf2 = Keyframe(3, 10.0)
    kf3 = Keyframe(6, 0.0)

    animation = Animation(
        [kf1, kf2, kf3],
        [sineio(), linear()]
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
    @test easings(anim) == [linear(), saccadic(2), sineio()]
end

@testset "animation creation rel values" begin
    anim = Animation(
        0, 3,
        rel(2), 4,
        rel(1), 3
    )
    @test timestamps(anim) == [0, 2, 3]
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
        sineio()
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
        sineio()
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
        noease()
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
        linear(n=3, yoyo=true)
    )

    results = [0.0, 0.25, 0.5, 0.75, 1.0, 0.75, 0.5, 0.25, 0.0, 0.25, 0.5, 0.75, 1.0]
    @test animation.(collect(0:0.25:3)) == results

end

@testset "even yoyo" begin
    animation = Animation(
        [1, 3],
        [0.0, 1.0],
        linear(n=2, yoyo=true)
    )

    @test animation.(0:4) == [0, 0, 1, 0, 0]
end

@testset "mixed easing" begin
    animation = Animation(
        [0, 1],
        [0, 1],
        mixed(sineio(), polyin(2))
    )
    @test animation(0) == 0
    @test animation(1) == 1
end

@testset "multiplied easing" begin
    animation = Animation(
        [0, 1],
        [0, 1],
        multiplied(sineio(), polyin(2))
    )
    @test animation(0) == 0
    @test animation(1) == 1
end

@testset "eased easing" begin
    animation = Animation(
        [0, 1],
        [0, 1],
        eased(sineio(), polyin(2), saccadic(2))
    )
    @test animation(0) == 0
    @test animation(1) == 1
end

@testset "loop" begin
    animation = Animation(
        0, 0.0,
        sineio(n=2, yoyo=true),
        2, 1.0
    )
    loop = Loop(animation, 0, 1, 2)
    @test loop(0) == 0
    @test loop(1) == 1
    @test loop(2) == 0
    @test loop(2.5) == 0
    @test loop(3) == 0
    @test loop(4) == 1
    @test loop(5) == 0
    @test loop(7) == 0 # two loops done
end

@testset "sequence" begin
    anim1 = Animation(
        0, 0.0,
        1, 1.0,
    )
    anim2 = Animation(
        0, 1.0,
        1, 0.0
    )
    sequence = Sequence([anim1, anim2], 1, 1)
    @test sequence(0) == 0.0
    @test sequence(1) == 0.0
    @test sequence(1.5) == 0.5
    @test sequence(2) == 1.0
    @test sequence(2.5) == 1.0
    @test sequence(3) == 1.0
    @test sequence(3.5) == 0.5
    @test sequence(4) == 0.0
    @test sequence(5) == 0.0
end

@testset "sequence with loop" begin
    anim1 = Animation(
        0, 0.0,
        1, 1.0,
    )
    anim2 = Animation(
        0, 1.0,
        1, 0.0
    )
    loop = Loop(anim2, 0, 1, 2)
    sequence = Sequence([anim1, loop], 1, 1)
    @test sequence(0) == 0.0
    @test sequence(1) == 0.0
    @test sequence(1.5) == 0.5
    @test sequence(2) == 1.0
    @test sequence(2.5) == 1.0
    # start of loop
    @test sequence(3) == 1.0
    @test sequence(3.5) == 0.5
    @test sequence(4) == 0.0
    @test sequence(4.5) == 0.0
    @test sequence(5) == 1.0
    @test sequence(5.5) == 0.5
    @test sequence(6) == 0.0
    @test sequence(7) == 0.0
end


@testset "animate_async" begin

    anim = Animation([0, 2], [5.0, 10.0])

    loopanim = Animation(
        0, 4.0,
        sineio(n=2, yoyo=true),
        2, 9.0
    )
    loop = Loop(loopanim, 0, 1, 2)

    anim1 = Animation(
        0, 3.0,
        1, 1.0,
    )
    anim2 = Animation(
        0, 1.0,
        1, 8.0
    )
    sequence = Sequence([anim1, anim2], 1, 1)

    vals = [0.0, 0.0, 0.0]
    last_t = Ref(0.0)
    animate_async(anim, loop, sequence; duration = 0.1, fps = 30) do t, an, lo, se
        last_t[] = t
        vals[1] = an
        vals[2] = lo
        vals[3] = se
    end |> wait

    t = last_t[]
    @test vals == [anim(t), loop(t), sequence(t)]

    starttime = time()
    timeref = Ref(time())
    # start long loop to then stop it prematurely
    animtask = animate_async(Loop(anim, 0, 0, 1000); duration = 5) do t, lo
        timeref[] = time()
    end
    stop(animtask)
    # give the task the opportunity to keep running
    sleep(0.5)

    @test timeref[] - starttime < 0.1 # stupid way to test that the loop didn't run much after stopping
end