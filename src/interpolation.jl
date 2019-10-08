function fraction_to_repeated(time_fraction::Real, n_repeats::Int, yoyo::Bool, prewait, postwait)
    # the 1 values should be reached, so no simple modulo
    # that means there are no zeros after the first, but 1 at the end is more important

    if time_fraction == 0
        return 0
    elseif time_fraction == 1
        # if there is an even yoyo value it needs to come down to zero at the end
        if yoyo && n_repeats % 2 == 0
            return 0
        else
            return 1
        end
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
    time_fraction_unclamped = (t - k1.t) / (k2.t - k1.t)

    # this is so the even yoyos work, the time value needs to go through the easing
    # but at least it's clamped
    time_fraction = clamp(time_fraction_unclamped, 0, 1)

    # if time_fraction <= 0
    #     return k1.value
    # elseif time_fraction >= 1
    #     return k2.value
    # end

    # handle repetitions
    # on the previous interval of 0 to 1 there are now n 0 to 1 intervals
    # this is the interval from 0 to 1 on which the easing function will be applied
    interp_fraction = fraction_to_repeated(time_fraction, easing.n, easing.yoyo, easing.prewait, easing.postwait)

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
function linear_interpolate(fraction::Real, array1::T, array2::T) where T <: AbstractArray
    linear_interpolate.(fraction, array1, array2)
end

function linear_interpolate(fraction::Real, c1::T, c2::T) where T <: Colors.Colorant
    Colors.weighted_color_mean(1 - fraction, c1, c2)
end

function interpolation_ratio(easing::FuncEasing, fraction)
    easing.f(fraction, easing.args...)
end

function interpolation_ratio(easing::MixedEasing, fraction)
    e1 = easing.e1
    e2 = easing.e2
    interp_fraction1 = fraction_to_repeated(fraction, e1.n, e1.yoyo, e1.prewait, e1.postwait)
    interp_fraction2 = fraction_to_repeated(fraction, e2.n, e2.yoyo, e2.prewait, e2.postwait)
    interpolation_ratio(easing.e1.easing, interp_fraction1) * easing.mix + interpolation_ratio(easing.e2.easing, interp_fraction2) * (1 - easing.mix)
end

function interpolation_ratio(easing::MultipliedEasing, fraction)
    e1 = easing.e1
    e2 = easing.e2
    interp_fraction1 = fraction_to_repeated(fraction, e1.n, e1.yoyo, e1.prewait, e1.postwait)
    interp_fraction2 = fraction_to_repeated(fraction, e2.n, e2.yoyo, e2.prewait, e2.postwait)
    interpolation_ratio(easing.e1.easing, interp_fraction1) * interpolation_ratio(easing.e2.easing, interp_fraction2)
end

function interpolation_ratio(easing::EasedEasing, fraction)
    e1 = easing.e1
    e2 = easing.e2
    ease = easing.easing
    interp_fraction1 = fraction_to_repeated(fraction, e1.n, e1.yoyo, e1.prewait, e1.postwait)
    interp_fraction2 = fraction_to_repeated(fraction, e2.n, e2.yoyo, e2.prewait, e2.postwait)
    interp_fraction_ease = fraction_to_repeated(fraction, ease.n, ease.yoyo, ease.prewait, ease.postwait)
    final = interpolation_ratio(easing.e1.easing, interp_fraction1) * (1 - interp_fraction_ease) +
            interpolation_ratio(easing.e2.easing, interp_fraction2) * interp_fraction_ease
end
