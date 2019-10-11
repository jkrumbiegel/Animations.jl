struct Loop{T}
    animation::Animation{T}
    start::Float64
    gap::Float64
    repetitions::Union{Nothing, Int}

    function Loop(a::Animation{T}, start::Real = 0, gap::Real = 0, repetitions::Union{Nothing, Int} = nothing) where T
        if gap < 0
            error("Gap cannot be smaller than zero, but is $gap")
        end

        if !isnothing(repetitions) && repetitions < 1
            error("Repetitions must be nothing or a positive integer, not $repetitions")
        end

        # animation should start at zero
        a_zeroed = a - timestamps(a)[1]

        new{T}(a_zeroed, start, gap, repetitions)
    end
end


function at(l::Loop, t::Real)
    duration = keyframes(l.animation)[end].t
    duration_gapped = duration + l.gap

    if isnothing(l.repetitions)
        t_within_animation = (t - l.start) % duration_gapped
        at(l.animation, t_within_animation)
    else
        n_repetitions_done, t_within_animation = divrem(t - l.start, duration_gapped)
        if n_repetitions_done >= l.repetitions
            at(l.animation, t - l.start)
        else
            at(l.animation, t_within_animation)
        end
    end
end

(l::Loop)(t::Real) = at(l, t)

Base.Broadcast.broadcastable(l::Loop) = Ref(l)
