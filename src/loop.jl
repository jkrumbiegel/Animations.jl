struct Loop{T} <: FiniteLengthAnimation{T}
    animation::FiniteLengthAnimation{T}
    start::Float64
    gap::Float64
    repetitions::Int

    function Loop(a::FiniteLengthAnimation{T}, tstart::Real, gap::Real, repetitions::Int) where T
        if gap < 0
            error("Gap cannot be smaller than zero, but is $gap")
        end

        if repetitions < 1
            error("Repetitions must be a positive integer, not $repetitions")
        end

        # animation should start at zero
        if start(a) != 0
            error("First timestamp of an animation in a loop must be 0, not $(start(a)).")
        end

        new{T}(a, tstart, gap, repetitions)
    end
end


function at(l::Loop{T}, t::Real)::T where {T}
    s = stop(l.animation)
    duration_gapped = s + l.gap

    n_repetitions_done, t_within_animation = divrem(t - l.start, duration_gapped)
    if n_repetitions_done >= l.repetitions
        at(l.animation, t - l.start)
    else
        at(l.animation, t_within_animation)
    end
end

(l::Loop)(t::Real) = at(l, t)

duration(l::Loop) = (duration(l.animation) + l.gap) * l.repetitions
