struct Keyframe{T}
    t::Float64
    value::T
end

Keyframe(t::Real, value) = Keyframe(convert(Float64, t), value)

Base.:+(kf::Keyframe, t::Real) = Keyframe(kf.t + t, kf.value)
Base.:-(kf::Keyframe, t::Real) = Keyframe(kf.t - t, kf.value)
Base.:*(kf::Keyframe, stretch::Real) = Keyframe(kf.t * stretch, kf.value)
Base.:/(kf::Keyframe, compress::Real) = Keyframe(kf.t / compress, kf.value)

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
