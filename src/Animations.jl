module Animations

import Observables

export Easing, LinearEasing, SineEasing, Animation, Keyframe, add!, update!, linear_interpolate

abstract type Easing end

struct LinearEasing <: Easing end
struct SineEasing <: Easing end
struct StepEasing <: Easing end

struct Keyframe{T}
    t::Float64
    value::T
end

Keyframe(t::Real, value) = Keyframe(convert(Float64, t), value)

struct Animation{T}
    observable::Observables.Observable{T}
    frames::Vector{Keyframe{T}}
    easings::Vector{Easing}

    function Animation(kfs::Vector{Keyframe{T}}, easings::Vector{Easing}) where T

        # create the observable from the first value
        obs = Observables.Observable{T}(kfs[1].value)

        validate_keyframe_times(kfs)

        if length(kfs) - length(easings) != 1
            error(
                """
                There must be one more keyframe than easings.
                There are $(length(kfs)) keyframes but only $(length(easings)) easings.
                """)
        end

        new{T}(obs, kfs, easings)
    end

    function Animation(differenttype_kfs::Vector{Keyframe}, easings::Vector{Easing})
        types = unique(map(x -> typeof(x), differenttype_kfs))
        error("""All keyframes need the same parametric type. Types are:\n$types""")
    end
end
Base.Broadcast.broadcastable(a::Animation) = Ref(a)

Observables.on(f::Function, a::Animation) = Observables.on(f, a.observable)
# Observables.map(a::Animation, f::Function) =

function update!(a::Animation, t::Real)

    # the first keyframe with a higher time is the second one of the two with
    # t in between (except when t is before the first or after the last keyframe)
    i_first_after_t = findfirst(kf -> kf.t >= t, a.frames)

    if isnothing(i_first_after_t)
        # t after last keyframe
        a.observable[] = a.frames[end].value
    elseif i_first_after_t == 1
        # t before first keyframe
        a.observable[] = a.frames[1].value
    else
        # t between two keyframes
        i_from = i_first_after_t - 1
        i_to = i_first_after_t
        a.observable[] = interpolate(a.easings[i_from], t, a.frames[i_from], a.frames[i_to])
    end
end

function validate_keyframe_times(kfs::Vector{Keyframe{T}}) where T

    if length(kfs) > 1
        for (k1, k2) in zip(kfs[1:end-1], kfs[2:end])
            if k2.t <= k1.t
                error("Keyframes are not ordered correctly, t=$(k1.t) before t2=$(k2.t)")
            end
        end
    end

    for k in kfs
        if isnan(k.t)
            error("t is NaN")
        end
    end

end

function interpolate(easing::Easing, t::Real, k1::Keyframe{T}, k2::Keyframe{T}) where T
    if t <= k1.t
        return k1.value
    elseif t >= k2.t
        return k2.value
    end

    time_fraction = (t - k1.t) / (k2.t - k1.t)
    interp_ratio = interpolation_ratio(easing, time_fraction)
    interp_value = linear_interpolate(interp_ratio, k1.value, k2.value)
end

# this should be overloaded for weird types
function linear_interpolate(fraction::Real, value1::T, value2::T) where T
    (value2 .- value1) .* fraction .+ value1
end

function interpolation_ratio(easing::SineEasing, fraction)
    return sin(pi * fraction - 0.5pi) * 0.5 + 0.5
end

function interpolation_ratio(easing::LinearEasing, fraction)
    return fraction
end

function interpolation_ratio(easing::StepEasing, fraction)
    return fraction <= 0.5 ? 0 : 1
end

end

# dump(:(1, 2, 3, 4, :5, 5r))
