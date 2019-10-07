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

function Animation(timestamps::AbstractVector{<:Real}, values::AbstractVector{T}, easings::AbstractVector{<:Easing}) where T
    keyframes = Keyframe{T}.(timestamps, values)
    Animation(keyframes, easings)
end

function Animation(timestamps::AbstractVector{<:Real}, values::AbstractVector{T}, easing::Easing=linease()) where T
    Animation(timestamps, values, Easing[easing for _ in 1:(length(timestamps) - 1)])
end

function Animation(args...; defaulteasing=Easing())

    timestamps = Float64[]
    valtype = typeof(args[2])
    values = Vector{valtype}()
    easings = Easing[]

    push!(timestamps, args[1])
    last = :time
    i = 2
    while i <= length(args)
        if last == :time
            if typeof(args[i]) <: valtype
                push!(values, args[i])
            else
                error("Value with type <: $valtype expected after timestamp at index $i. Got $(typeof(args[i])) instead.")
            end
            last = :value
        elseif last == :value
            if typeof(args[i]) <: Easing
                push!(easings, args[i])
                last = :easing
            elseif typeof(args[i]) <: Real
                push!(easings, defaulteasing)
                push!(timestamps, args[i])
                last = :time
            else
                error("Timestamp with type <: Real or easing with type <: Easing expected after value at index $i. Got $(typeof(args[i])) instead.")
            end
        elseif last == :easing
            if typeof(args[i]) <: Real
                push!(timestamps, args[i])
            else
                error("Timestamp with type <: Real expected after easing at index $i. Got $(typeof(args[i])) instead.")
            end
            last = :time
        end

        i += 1
    end

    if last == :time
        error("Last value can't be a timestamp.")
    elseif last == :easing
        error("Last value can't be an easing")
    end

    Animation(timestamps, values, easings)
end

Base.Broadcast.broadcastable(a::Animation) = Ref(a)

Base.:+(a::Animation, t::Real) = Animation(a.frames .+ t, a.easings)
Base.:-(a::Animation, t::Real) = Animation(a.frames .- t, a.easings)
Base.:*(a::Animation, stretch::Real) = Animation(a.frames .* stretch, a.easings)
Base.:/(a::Animation, compress::Real) = Animation(a.frames ./ compress, a.easings)

easings(a::Animation) = a.easings
timestamps(a::Animation) = [kf.t for kf in a.frames]
keyframes(a::Animation) = a.frames
keyvalues(a::Animation) = [kf.value for kf in a.frames]

function at(a::Animation, t::Real)
    # the first keyframe with a higher time is the second one of the two with
    # t in between (except when t is before the first or after the last keyframe)
    i_first_after_t = findfirst(kf -> kf.t >= t, a.frames)

    if isnothing(i_first_after_t)
        # t lies after the last keyframe
        # return a.frames[end].value
        return interpolate(a.easings[end], t, a.frames[end-1], a.frames[end])
    elseif i_first_after_t == 1
        # t lies before the first keyframe
        # return a.frames[1].value
        return interpolate(a.easings[1], t, a.frames[1], a.frames[2])
    else
        # t lies between two keyframes
        i_from = i_first_after_t - 1
        i_to = i_first_after_t
        return interpolate(a.easings[i_from], t, a.frames[i_from], a.frames[i_to])
    end
end

function (a::Animation)(t::Real)
    at(a, t)
end

function update!(a::Animation, t::Real)
    observable(a)[] = at(a, t)
end

Observables.on(f::Function, a::Animation) = Observables.on(f, observable(a))

value(a::Animation) = observable(a)[]

observable(a::Animation) = a.obs


value(a::Animation) = a.obs[]
