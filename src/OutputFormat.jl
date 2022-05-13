module OutputFormat
include("./InputParser.jl")
include("./ModelBehaviour.jl")
using .InputParser
using .ModelBehaviour

export OutputData, performWriteModelOutput, performGetModelOutput, performGetModelValue, writeOutput, getHeader

# Output Data Struct
struct OutputData
    inputData::InputData
    # When I tried passing in an InputData object
    # directly there were lots of errors
    OutputData(path::String) = new(InputData(path))
end

# Function to write outputs in order we want
function writeOutput(order::Array{Function}, outputData::OutputData, path::String)
    # w - overwrite file contents 
    open(path, "w") do file
        i = 1
        for f in order
            write(file, f(outputData))
            i += 1
        end
    end
end

### CONSTANT BEHAVIOUR FUNCTIONS ###
# TODO: writeHeader, getHeaderValues
getHeader(outputData::OutputData) = "Title: $(outputData.inputData.problemName)\nNodal Points: $(outputData.inputData.nodalPoints), Base Nodal Point Index: $(outputData.inputData.bottomPointIndex)\n"
####################################

### CHANGING BEHAVIOUR FUNCTIONS ###
# ModelOutputBehaviour
performWriteModelOutput(outputData::OutputData, path::String) = ModelBehaviour.writeOutput(getModelOutBehaviour(outputData), path)
performGetModelOutput(outputData::OutputData) = ModelBehaviour.getModelOutput(getModelOutBehaviour(outputData))
performGetModelValue(outputData::OutputData) = ModelBehaviour.getModelValue(getModelOutBehaviour(outputData))
####################################


### Get behaviour instances  ######
# Get ModelOutputBehaviour Instance
function getModelOutBehaviour(outputData::OutputData)::ModelBehaviour.ModelOutputBehaviour
    modelOutBehaviour = 0
    # Get instance of ModelOutputBehaviour given Model
    if outputData.inputData.model == InputParser.ConsolidationSwell
        modelOutBehaviour = ModelBehaviour.ConsolidationSwellBehaviour()
    elseif outputData.inputData.model == InputParser.LeonardFrost
        modelOutBehaviour = ModelBehaviour.LeonardFrostBehaviour()
    elseif outputData.inputData.model == InputParser.Schmertmann
        modelOutBehaviour = ModelBehaviour.SchmertmannBehaviour()
    elseif outputData.inputData.model == InputParser.SchmertmannElastic
        modelOutBehaviour = ModelBehaviour.SchmertmannElasticBehaviour()
    else
        modelOutBehaviour = ModelBehaviour.CollapsibleSoilBehaviour()
    end
    return modelOutBehaviour
end
####################################

end # module