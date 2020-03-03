struct Sequence{T} <: FiniteLengthAnimation{T}
    animations::Vector{<:FiniteLengthAnimation{T}}
    start::Float64
    gaps::Vector{Float64}
end

function Sequence(animations::Vector{<:FiniteLengthAnimation{T}}, start::Real, gap::Real) where T
    Sequence(animations, convert(Float64, start), Float64[gap for _ in 1:length(animations) - 1])
end

function at(s::Sequence{T}, t::Real)::T where {T}
    durations = duration.(s.animations)
    d = duration(s)
    boundaries = [s.start; s.start .+ durations[1:end-1] .+ s.gaps; s.start + d]

    i_first_after_t = findfirst(b -> b >= t, boundaries)

    if isnothing(i_first_after_t)
        # t lies after the last boundary
        return at(s.animations[end], t - boundaries[end-1])
    elseif i_first_after_t == 1
        # t lies before the first boundary
        return at(s.animations[1], t - boundaries[1])
    else
        # t lies between two boundaries
        i_from = i_first_after_t - 1
        return at(s.animations[i_from], t - boundaries[i_from])
    end
end

(s::Sequence)(t::Real) = at(s, t)

duration(s::Sequence) = sum(s.gaps) + sum(duration.(s.animations))
