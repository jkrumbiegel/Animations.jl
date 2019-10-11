struct Loop{T}
    animation::Animation{T}
    start::Float64
    gap::Float64
    repetitions::Int

    function Loop(a::Animation{T}, start::Real, gap::Real, repetitions::Int) where T
        if gap < 0
            error("Gap cannot be smaller than zero, but is $gap")
        end

        if repetitions < 1
            error("Repetitions must be a positive integer, not $repetitions")
        end

        # animation should start at zero
        if timestamps(a)[1] != 0
            error("First timestamp of an animation in a loop must be 0, not $(timestamps(a)[1]).")
        end

        new{T}(a, start, gap, repetitions)
    end
end


function at(l::Loop, t::Real)
    duration = keyframes(l.animation)[end].t
    duration_gapped = duration + l.gap

    n_repetitions_done, t_within_animation = divrem(t - l.start, duration_gapped)
    if n_repetitions_done >= l.repetitions
        at(l.animation, t - l.start)
    else
        at(l.animation, t_within_animation)
    end
end

(l::Loop)(t::Real) = at(l, t)

Base.Broadcast.broadcastable(l::Loop) = Ref(l)
