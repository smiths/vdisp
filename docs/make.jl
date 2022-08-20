using Documenter
using vdisp

include("../src/OutputFormat/CalculationBehaviour.jl")
using .CalculationBehaviour

include("../src/InputParser.jl")
using .InputParser

pages = [
    "Home" => "index.md",
    "VDisp Users" => [
        "Calculations" => "VDispUsers/Calculations.md",
        "Input Files" => "VDispUsers/InputFiles.md"
    ],
    "VDisp Developers" => [
        "VDisp Artifacts" => "VDispDevelopers/VDisplArtifacts.md"
    ]
]

makedocs(
    sitename = "vdisp",
    authors = "Emil Soleymani and Dr. Spencer Smith",
    format = Documenter.HTML(),
    pages = pages,
    modules = [vdisp, CalculationBehaviour, InputParser]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/smiths/vdisp.git"
)
