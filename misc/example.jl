using Revise
using Layered
using Animations
using Colors


function test()

    duration = 6

    a_y = Animation(
        0, 1,
        polyout(2; n=8, yoyo=true),
        duration, 0)

    a_x = Animation(
        0, 0,
        linear(n=2, yoyo=true),
        duration, 1)

    a_color = Animation(
        0, RGB(0.251, 0.388, 0.847),
        duration * 0.25, RGB(0.22, 0.596, 0.149),
        duration * 0.5, RGB(0.584, 0.345, 0.698),
        duration * 0.75, RGB(0.796, 0.235, 0.2),
        defaulteasing=noease()
    )


    function frame(t)
        c, tl = canvas(2, 2)

        l = layer_in_rect!(tl, c.rect, :w, :norm, margin=30)

        circle!(l, P(a_x(t), a_y(t)), 0.15) + Fill(a_color(t)) + Stroke(nothing)

        c

    end

    filepath = joinpath(dirname(pathof(Animations)), "../misc/example.gif")
    record(frame, filepath, 30, duration)

end; test()
