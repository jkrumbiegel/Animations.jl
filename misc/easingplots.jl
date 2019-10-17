using PyPlot
using Animations


function easingplots()

    efuncs = [noease, stepease, linear, sineio, saccadic, expin, expout, polyin, polyout]
    params = [[nothing], [0.25, 0.5, 0.75], [nothing], [nothing], [1, 2, 4], [0.2, 2, 8], [0.2, 2, 8], [2, 3, 6], [2, 3, 6]]

    n = length(efuncs)
    cols = 3
    rows = Int(ceil(n / cols))
    fig, axes = subplots(rows, cols, figsize=(5, rows/3*4), constrained_layout=true)

    xx = 0:0.005:1

    for (i, (ef, ps)) in enumerate(zip(efuncs, params))

        a = axes[(divrem(i - 1, cols) .+ (1, 1))...]
        a.axis("off")

        a.plot([-0.25, 0], [0, 0], color=(0.5, 0.5, 0.5), linestyle="dotted")
        a.plot([1, 1.25], [1, 1], color=(0.5, 0.5, 0.5), linestyle="dotted")
        a.set_title("$(Symbol(ef))", fontweight=600)
        for p in ps
            easing = isnothing(p) ? ef() : ef(p)
            anim = Animation([0, 1], [0.0, 1.0], easing)
            yy = at.(anim, xx)
            if isnothing(p)
                a.plot(xx, yy)
            else
                a.plot(xx, yy, label="$p")
            end
        end
        if ps != [nothing]
            a.legend(loc="center", bbox_to_anchor=(1, 0.5), frameon=false, borderpad=0, borderaxespad=0, handlelength=0.5)
        end
    end

    fig.savefig(joinpath(dirname(pathof(Animations)), "../misc/easingplots.svg"))

end
easingplots()
