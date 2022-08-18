using Documenter
using vdisp

include("../src/OutputFormat/CalculationBehaviour.jl")
using .CalculationBehaviour

include("../src/InputParser.jl")
using .InputParser

makedocs(
    sitename = "vdisp",
    format = Documenter.HTML(),
    modules = [vdisp, CalculationBehaviour, InputParser]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/smiths/vdisp.git"
)
