macro async_showerr(ex)
    quote
        t = @async try
            eval($(esc(ex)))
        catch err
            bt = catch_backtrace()
            println("Asynchronous animation errored:")
            showerror(stderr, err, bt)
        end
    end
end


"""
    animate_async(f::Function, anims::FiniteLengthAnimation...; duration::Real, fps::Int = 30)

Start an asynchronous animation where in each frame `f` is called with the current
animation time as well as the current value of each `Animation` in `anims`.

Example:

    animate_async(anim1, anim2) do t, a1, a2
        # do something (e.g. with a plot or other visual object)
    end
"""
function animate_async(f::Function, anims::FiniteLengthAnimation...; duration::Real, fps::Int = 30)

    frameduration = 1 / fps

    t_start = time()
    t_target = t_start

    @async_showerr while true

        t_current = time()
        t_relative = t_current - t_start

        f(t_relative, (a(t_relative) for a in anims)...)

        if t_relative >= duration
            break
        end

        # always try to hit the next target exactly one frame duration away from
        # the last to avoid drift
        t_target += frameduration
        sleeptime = t_target - time()
        sleep(max(0.001, sleeptime))
    end
end
