module vdisp

include("./OutputFormat/OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser

export readInputFile

"""
    readInputFile(inputPath, outputPath)

Reads and parses input file at inputPath and outputs calculations to file at outputPath
"""
function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)

    writeDefaultOutput(outputData, outputPath)
end

if size(ARGS)[1] == 2
    readInputFile(ARGS[1], ARGS[2])
end

end # module
