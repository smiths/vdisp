module vdisp

include("./OutputFormat/OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser

export readInputFile

function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)
    
    header = OutputFormat.getHeader
    model = OutputFormat.performGetModelOutput
    foundationOut = OutputFormat.performGetFoundationOutput
    displacementInfo = OutputFormat.performGetDisplacementOutput
    equilibriumInfo = OutputFormat.performGetEquilibriumOutput
    forcePointOut = OutputFormat.performGetForcePointOutput
    foundationDepth = OutputFormat.getFoundationDepth
    soilTable = OutputFormat.getSoilTable
    calculationOut = OutputFormat.performGetCalculationOutput

    OutputFormat.writeOutput([header, model, foundationOut, foundationDepth, soilTable ,displacementInfo, equilibriumInfo, forcePointOut, calculationOut], outputData, outputPath)
end

if size(ARGS)[1] == 2
    readInputFile(ARGS[1], ARGS[2])
end

end # module
