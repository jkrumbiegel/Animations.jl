abstract type EasingType end

struct Easing{T <: EasingType}
    easing::T
    n::Int
    yoyo::Bool
    prewait::Float64
    postwait::Float64
end

struct LinearEasing <: EasingType end
struct SineIOEasing <: EasingType end
struct NoEasing <: EasingType end
struct StepEasing <: EasingType end
struct SaccadicEasing <: EasingType
    power::Float64
end

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

struct PolyOutEasing <: EasingType
    power::Float64
end

struct ExpInEasing <: EasingType
    exponent::Float64
    function ExpInEasing(exp)
        if exp == 1
            error("Exponent base can't be 1.")
        end
        new(exp)
    end
end

Easing(easing=LinearEasing(); n=1, yoyo=false, prewait=0.0, postwait=0.0) = Easing(easing, n, yoyo, prewait, postwait)

noease(;kwargs...) = Easing(NoEasing(); kwargs...)
stepease(;kwargs...) = Easing(StepEasing(); kwargs...)
sineio(;kwargs...) = Easing(SineIOEasing(); kwargs...)
saccadic(power; kwargs...) = Easing(SaccadicEasing(power); kwargs...)
linease(;kwargs...) = Easing(LinearEasing(); kwargs...)
polyin(power; kwargs...) = Easing(PolyInEasing(power); kwargs...)
polyout(power; kwargs...) = Easing(PolyOutEasing(power); kwargs...)
expin(exponent; kwargs...) = Easing(ExpInEasing(exponent); kwargs...)

Base.Broadcast.broadcastable(e::Easing) = Ref(e)
