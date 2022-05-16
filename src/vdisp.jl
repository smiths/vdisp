module vdisp

include("./OutputFormat/OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser

export lerp, readInputFile

function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)
    
    header = OutputFormat.getHeader
    model = OutputFormat.performGetModelOutput
    foundation = OutputFormat.performGetFoundationOutput
    displacementInfo = OutputFormat.performGetDisplacementOutput
    equilibriumInfo = OutputFormat.performGetEquilibriumOutput

    OutputFormat.writeOutput([header, model, foundation, displacementInfo, equilibriumInfo], outputData, outputPath)
end

end # module
