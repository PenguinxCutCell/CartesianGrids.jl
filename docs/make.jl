using Documenter
using CartesianGrids

makedocs(
    modules = [CartesianGrids],
    authors = "PenguinxCutCell contributors",
    sitename = "CartesianGrids.jl",
    format = Documenter.HTML(
        canonical = "https://PenguinxCutCell.github.io/CartesianGrids.jl",
        repolink = "https://github.com/PenguinxCutCell/CartesianGrids.jl",
        collapselevel = 2,
    ),
    pages = [
        "Home" => "index.md",
        "Grid Types" => "grid-types.md",
        "API Reference" => "reference.md",
    ],
    pagesonly = true,
    warnonly = true,
    remotes = nothing,
)

# Only deploy docs if running in CI environment
if get(ENV, "CI", "") == "true"
    deploydocs(
        repo = "github.com/PenguinxCutCell/CartesianGrids.jl",
        push_preview = true,
    )
end
