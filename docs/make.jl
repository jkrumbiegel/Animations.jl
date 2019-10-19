using Documenter, Animations

makedocs(
    sitename="Animations.jl",
    format = Documenter.HTML(
            prettyurls = get(ENV, "CI", nothing) == "true"
        )
    )

deploydocs(
    repo = "github.com/jkrumbiegel/Animations.jl.git",
)
