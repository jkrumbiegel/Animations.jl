"""
    AnimationTask

A thin wrapper around a `Task` together with an interrupt_switch that signals
the animation loop to exit.
"""
struct AnimationTask
    task::Task
    interrupt_switch::Ref{Bool}
end

macro async_showerr(ex)
    quote
        animationtask = @async try
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

Returns an `AnimationTask` which can be stopped with `stop(animationtask)`.

Example:

    animate_async(anim1, anim2) do t, a1, a2
        # do something (e.g. with a plot or other visual object)
    end
"""
function animate_async(f::Function, anims::FiniteLengthAnimation...;
        duration = maximum(duration, anims),
        fps::Int = 30)

    frameduration = 1 / fps

    t_start = time()
    t_target = t_start

    interrupt_switch = Ref(false)

    task = @async_showerr while !interrupt_switch[]

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

    AnimationTask(task, interrupt_switch)
end

"""
    stop(at::AnimationTask)

Stop a running `AnimationTask`. This only sets a flag for the animation loop to
exit, it won't kill a task that is stuck. You can manipulate the `Task` stored
in the `AnimationTask` directly if you need more control.
"""
stop(at::AnimationTask) = at.interrupt_switch[] = true

Base.wait(at::AnimationTask) = wait(at.task)
