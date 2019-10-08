using Revise
using Layered
using Animations
using Colors


function test()

    duration = 4

    a_points = Animation(
        0, reshape(P.(rand(25), rand(25)), (5, 5)),
        sineio(n=2, yoyo=true, prewait=0.3),
        duration, P.(grid(LinRange(0, 1, 5), LinRange(0, 1, 5))...))


    function frame(t)
        c, tl = canvas(2, 2)

        l = layer_in_rect!(tl, c.rect, :w, :norm, margin=30)

        circles!(l) do
            Circle.(a_points(t), 0.05)
        end + Fill(:frac => f -> LCHuv(70, 70, f * 360)) + Stroke(nothing)

        c

    end

    filepath = joinpath(dirname(pathof(Animations)), "../misc/example_array.gif")
    record(frame, filepath, 30, duration)

end; test()
