module Animations

using Observables: Observable

export Easing, LinearEasing, SineEasing, Animator, Animation, Keyframe, evaluate, add!, update

abstract type Easing end

struct LinearEasing <: Easing end
struct SineEasing <: Easing end

struct Keyframe{T}
    t::Float64
    value::T
end

Keyframe(t::Real, value) = Keyframe(convert(Float64, t), value)

struct Animation{T}
    frames::Vector{Keyframe{T}}
    easings::Vector{Easing}

    function Animation(kfs::Vector{Keyframe{T}}, easings::Vector{Easing}) where T
        validate_keyframe_times(kfs)

        if length(kfs) - length(easings) != 1
            error(
                """
                There must be one more keyframe than easings.
                There are $(length(kfs)) keyframes but only $(length(easings)) easings.
                """)
        end

        new{T}(kfs, easings)
    end
end

mutable struct Animator
    animations::IdDict{Observable, Animation}
end

Animator() = Animator(IdDict{Observable, Animation}())

function update(a::Animator, t::Real)
    for (observable, animation) in a.animations
        observable[] = evaluate(animation, t)
    end
end

function add!(animator::Animator, obs::Observable, a::Animation)
    animator.animations[obs] = a
end

function evaluate(a::Animation, t::Real)

    i_first_after_t = findfirst(kf -> kf.t >= t, a.frames)

    if isnothing(i_first_after_t)
        return a.frames[end].value
    elseif i_first_after_t == 1
        return a.frames[1].value
    else
        i_from = i_first_after_t - 1
        i_to = i_first_after_t
        return interpolate(a.easings[i_from], t, a.frames[i_from], a.frames[i_to])
    end
end

function validate_keyframe_times(kfs::Vector{Keyframe{T}}) where T

    if length(kfs) <= 1
        return
    end
    for (k1, k2) in zip(kfs[1:end-1], kfs[2:end])
        if k2.t <= k1.t
            error("Keyframes are not ordered correctly, t=$(k1.t) before t2=$(k2.t)")
        end
    end
end

function interpolate(kind::S, t::Real, k1::Keyframe{T}, k2::Keyframe{T}) where {S <: Easing, T}
    if t <= k1.t
        return k1.value
    elseif t >= k2.t
        return k2.value
    end

    time_fraction = (t - k1.t) / (k2.t - k1.t)
    interp_strength = strength(kind, time_fraction)
    interp_value = (k2.value .- k1.value) .* interp_strength .+ k1.value
end

function strength(kind::SineEasing, fraction)
    return sin(0.5pi + pi * fraction) * 0.5 + 0.5
end

function strength(kind::LinearEasing, fraction)
    return fraction
end

end

# dump(:(1, 2, 3, 4, :5, 5r))
