module Animations

import Observables

export Easing, EasingType, LinearEasing, SineIOEasing, NoEasing, StepEasing, CompressedExpEasing, EasedEasing, PolyInEasing
    MixedEasing, MultipliedEasing, Animation, Keyframe, add!, update!, linear_interpolate, @timestamps

abstract type EasingType end

struct Easing{T <: EasingType}
    easing::T
    ntimes::Int
    yoyo::Bool
    prewait::Float64
    postwait::Float64

    function Easing(easing, ntimes, yoyo, prewait, postwait)
        if yoyo && iseven(ntimes)
            error("Yoyo works only with odd numbers of repetitions, it has to reach 1 at the end.")
        end
        new{typeof(easing)}(easing, ntimes, yoyo, prewait, postwait)
    end
end

struct LinearEasing <: EasingType end
struct SineIOEasing <: EasingType end
struct NoEasing <: EasingType end
struct StepEasing <: EasingType end

"""
Mixes two easings with a constant ratio r, so that final = e1 * r + e2 * (1 - r)
"""
struct MixedEasing{S <: Easing, T <: Easing} <: EasingType
    e1::S
    e2::T
    mix::Float64

    function MixedEasing(e1::S, e2::T, mix::Float64=0.5) where {S <: Easing, T <: Easing}
        if !(0 <= mix <= 1)
            error("Mix has to be between 0 and 1, but is $mix")
        end
        new{S, T}(e1, e2, mix)
    end
end

"""
Multiplies two easings with each other, so final = e1 * e2
"""
struct MultipliedEasing{S <: Easing, T <: Easing} <: EasingType
    e1::S
    e2::T
end

"""
Mixes two easings with a factor decided with a third easing, so that
final = (1 - easing()) * e1 + easing() * e2
"""
struct EasedEasing{S <: Easing, T <: Easing, U <: Easing} <: EasingType
    e1::S
    e2::T
    easing::U

    function EasedEasing(e1, e2, easing=Easing(easing=LinearEasing()))
        new{typeof(e1), typeof(e2), typeof(easing)}(e1, e2, easing)
    end
end

"""
Polynomial in easing, so 2 is quad in, 3 is cubic in, etc
"""
struct PolyInEasing <: EasingType
    power::Float64
end

struct CompressedExpEasing <: EasingType
    compression::Float64
    _scaler99::Float64

    function CompressedExpEasing(compression::Float64)
        # compexp(t, comp) = 1 - exp(-(t ^ comp))
        # 0.99 = 1 - exp(-t ^ comp)
        # exp(-(t ^ comp)) = 0.01
        # (t ^ comp) = -log(0.01)
        t_99 = (-log(1 - 0.95)) ^ (1/compression)
        new(compression, t_99)
    end
end

Easing(;easing=NoEasing(), ntimes=1, yoyo=false, prewait=0.0, postwait=0.0) = Easing(easing, ntimes, yoyo, prewait, postwait)

struct Keyframe{T}
    t::Float64
    value::T
end

Keyframe(t::Real, value) = Keyframe(convert(Float64, t), value)

struct Animation{T}
    obs::Observables.Observable{T}
    frames::Vector{Keyframe{T}}
    easings::Vector{<:Easing}

    function Animation(kfs::Vector{Keyframe{T}}, easings::Vector{<:Easing}) where T

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

    function Animation(kfs::Vector{Keyframe{T}}, easing::Easing) where T
        if length(kfs) <= 1
            error("There must be at least two keyframes.")
        end
        Animation(kfs, Easing[easing for _ in 1:length(kfs) - 1])
    end

    function Animation(timestamps::Vector{<:Real}, values::Vector{T}, easings::Vector{<:Easing}) where T
        keyframes = Keyframe{T}.(timestamps, values)
        Animation(keyframes, easings)
    end

    function Animation(timestamps::Vector{<:Real}, values::Vector{T}, easing::Easing) where T
        Animation(timestamps, values, Easing[easing for _ in 1:(length(timestamps) - 1)])
    end


end
Base.Broadcast.broadcastable(a::Animation) = Ref(a)

Observables.on(f::Function, a::Animation) = Observables.on(f, a.obs)
# Observables.map(a::Animation, f::Function) =

function update!(a::Animation, t::Real)

    # the first keyframe with a higher time is the second one of the two with
    # t in between (except when t is before the first or after the last keyframe)
    i_first_after_t = findfirst(kf -> kf.t >= t, a.frames)

    if isnothing(i_first_after_t)
        # t after last keyframe
        a.obs[] = a.frames[end].value
    elseif i_first_after_t == 1
        # t before first keyframe
        a.obs[] = a.frames[1].value
    else
        # t between two keyframes
        i_from = i_first_after_t - 1
        i_to = i_first_after_t
        a.obs[] = interpolate(a.easings[i_from], t, a.frames[i_from], a.frames[i_to])
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

function fraction_to_repeated(time_fraction::Real, n_repeats::Int, yoyo::Bool, prewait, postwait)
    # the 1 values should be reached, so no simple modulo
    # that means there are no zeros after the first, but 1 at the end is more important

    if time_fraction == 0
        return 0
    elseif time_fraction == 1
        return 1
    elseif time_fraction > 1 || time_fraction < 0
        error("Time fraction is $time_fraction but should be from 0 to 1")
    end

    if !(0 <= prewait < 1)
        error("Pre-wait fraction $prewait is invalid")
    end
    if !(0 <= postwait < 1)
        error("Post-wait fraction $postwait is invalid")
    end
    if postwait + prewait >= 1
        error("Pre-wait is $prewait and post-wait is $postwait, together larger or equal to 1.")
    end

    multiplied = time_fraction * n_repeats
    multiples, rest = divrem(multiplied, 1)
    nth_repeat = Int(multiples) + 1 # because 1st repeat is 0 for divrem

    # this causes the value to be 0 for the prewait interval and 1 for the postwait interval
    repeat_fraction = clamp((rest - prewait) / ((1 - postwait) - prewait), 0, 1)

    if yoyo
        # 1: 0 to 1
        # 2: 1 to 0
        # 3: 0 to 1
        # etc
        if isodd(nth_repeat) # first up
            return repeat_fraction
        else
            return 1 - repeat_fraction # then down
        end
    else
        # this is different than standard modulo
        return rest == 0 ? 1 : repeat_fraction
    end
end

function interpolate(easing::Easing, t::Real, k1::Keyframe{T}, k2::Keyframe{T}) where T

    # the fraction of the keyframe interval we're at
    time_fraction = (t - k1.t) / (k2.t - k1.t)

    if time_fraction <= 0
        return k1.value
    elseif time_fraction >= 1
        return k2.value
    end

    # handle repetitions
    # on the previous interval of 0 to 1 there are now n 0 to 1 intervals
    # this is the interval from 0 to 1 on which the easing function will be applied
    interp_fraction = fraction_to_repeated(time_fraction, easing.ntimes, easing.yoyo, easing.prewait, easing.postwait)

    # this is the actual ratio of the two keyframe values that comes out of the esas
    interp_ratio = interpolation_ratio(easing.easing, interp_fraction)

    # these checks enable to return early if values are 0 or 1, which is why
    # NoEasing EasingType can be used for non-interpolateable values like strings
    if interp_ratio == 0
        return k1.value
    elseif interp_ratio == 1
        return k2.value
    end

    interp_value = linear_interpolate(interp_ratio, k1.value, k2.value)
end

# this should be overloaded for weird types
function linear_interpolate(fraction::Real, value1::T, value2::T) where T
    (value2 - value1) * fraction + value1
end

# array version with broadcasting
function linear_interpolate(fraction::Real, value1::T, value2::T) where T <: AbstractArray
    (value2 .- value1) .* fraction .+ value1
end

function interpolation_ratio(easing::SineIOEasing, fraction)
    sin(pi * fraction - 0.5pi) * 0.5 + 0.5
end

function interpolation_ratio(easing::LinearEasing, fraction)
    fraction
end

function interpolation_ratio(easing::StepEasing, fraction)
    fraction < 0.5 ? 0 : 1
end

function interpolation_ratio(easing::NoEasing, fraction)
    fraction == 1 ? 1 : 0
end

function interpolation_ratio(easing::CompressedExpEasing, fraction)
    (1 - exp(-(fraction * easing._scaler99 ^ easing.compression))) / 0.95
end

function interpolation_ratio(easing::MixedEasing, fraction)
    e1 = easing.e1
    e2 = easing.e2
    interp_fraction1 = fraction_to_repeated(fraction, e1.ntimes, e1.yoyo, e1.prewait, e1.postwait)
    interp_fraction2 = fraction_to_repeated(fraction, e2.ntimes, e2.yoyo, e2.prewait, e2.postwait)
    interpolation_ratio(easing.e1.easing, interp_fraction1) * easing.mix + interpolation_ratio(easing.e2.easing, interp_fraction2) * (1 - easing.mix)
end

function interpolation_ratio(easing::MultipliedEasing, fraction)
    e1 = easing.e1
    e2 = easing.e2
    interp_fraction1 = fraction_to_repeated(fraction, e1.ntimes, e1.yoyo, e1.prewait, e1.postwait)
    interp_fraction2 = fraction_to_repeated(fraction, e2.ntimes, e2.yoyo, e2.prewait, e2.postwait)
    interpolation_ratio(easing.e1.easing, interp_fraction1) * interpolation_ratio(easing.e2.easing, interp_fraction2)
end

function interpolation_ratio(easing::EasedEasing, fraction)
    e1 = easing.e1
    e2 = easing.e2
    ease = easing.easing
    interp_fraction1 = fraction_to_repeated(fraction, e1.ntimes, e1.yoyo, e1.prewait, e1.postwait)
    interp_fraction2 = fraction_to_repeated(fraction, e2.ntimes, e2.yoyo, e2.prewait, e2.postwait)
    interp_fraction_ease = fraction_to_repeated(fraction, ease.ntimes, ease.yoyo, ease.prewait, ease.postwait)
    final = interpolation_ratio(easing.e1.easing, interp_fraction1) * (1 - interp_fraction_ease) +
            interpolation_ratio(easing.e2.easing, interp_fraction2) * interp_fraction_ease
end

function interpolation_ratio(easing::PolyInEasing, fraction)
    fraction ^ easing.power
end

macro timestamps(args...)

    ts = Float64[args[1]]

    if length(args) > 1
        for a in args[2:end]
            if typeof(a) <: QuoteNode
                if isreal(a.value)
                    if a.value <= 0
                        error("Relative timestamp must be larger than 0, but is $(a.value)")
                    end
                    push!(ts, ts[end] + a.value)
                else
                    error("$(a.value) is not a number")
                end
            elseif typeof(a) <: Real
                if a <= ts[end]
                    error("$a is smaller than the previous timestamp $(ts[end])")
                end
                push!(ts, a)
            else
                error("$(a) is not a valid timestamp")
            end
        end
    end
    :($ts)
end

end
