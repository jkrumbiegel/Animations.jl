abstract type EasingType end

struct Easing{T <: EasingType}
    easing::T
    n::Int
    yoyo::Bool
    prewait::Float64
    postwait::Float64
end

struct FuncEasing <: EasingType
    f::Function
    args::Tuple

    function FuncEasing(f, args)
        f0 = f(0, args...)
        f1 = f(1, args...)
        if !(f0 == 0 && f1 == 1)
            error("The given easing function is not 0 and 1 at t = 0 and t = 1, but $f0 and $f1")
        end
        new(f, args)
    end
end

FuncEasing(f::Function) = FuncEasing(f, ())

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

Easing(easing = FuncEasing(f_linear); n=1, yoyo=false, prewait=0.0, postwait=0.0) = Easing(easing, n, yoyo, prewait, postwait)

function opposite(f)
    function opfunc(fraction, args...)
        1 - f(1 - fraction, args...)
    end
end

funcease(f, args...; kwargs...) = Easing(FuncEasing(f, args); kwargs...)

f_noease(fraction) = fraction == 1 ? 1 : 0
noease(;kwargs...) = funcease(f_noease; kwargs...)

f_stepease(fraction) = fraction < 0.5 ? 0 : 1
stepease(;kwargs...) = funcease(f_stepease; kwargs...)

f_sineio(fraction) = sin(pi * fraction - 0.5pi) * 0.5 + 0.5
sineio(;kwargs...) = funcease(f_sineio; kwargs...)

f_saccadic(fraction, power) = -(sin((-fraction + 1) ^ power * pi - pi/2) * 0.5 + 0.5) + 1
saccadic(power; kwargs...) = funcease(f_saccadic, power; kwargs...)

f_linear(fraction) = fraction
linear(;kwargs...) = funcease(f_linear; kwargs...)

f_polyin(fraction, power) = fraction ^ power
polyin(power; kwargs...) = funcease(f_polyin, power; kwargs...)

polyout(power; kwargs...) = funcease(opposite(f_polyin), power; kwargs...)

f_expin(fraction, exponent) = ((exponent ^ fraction) - 1) / (exponent - 1)
expin(exponent; kwargs...) = funcease(f_expin, exponent; kwargs...)

expout(exponent; kwargs...) = funcease(opposite(f_expin), exponent; kwargs...)

mixed(e1, e2; kwargs...) = Easing(MixedEasing(e1, e2); kwargs...)
multiplied(e1, e2; kwargs...) = Easing(MultipliedEasing(e1, e2); kwargs...)
eased(e1, e2, with_e; kwargs...) = Easing(EasedEasing(e1, e2, with_e); kwargs...)

Base.Broadcast.broadcastable(e::Easing) = Ref(e)
