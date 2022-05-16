module OutputFormat

include("../InputParser.jl")
include("./ModelBehaviour.jl")
include("./FoundationBehaviour.jl")
include("./DisplacementBehaviour.jl")
include("./EquilibriumBehaviour.jl")

using .InputParser
using .ModelBehaviour
using .FoundationBehaviour
using .DisplacementBehaviour
using .EquilibriumBehaviour

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
            # Seperate each section with empty line
            # We can make this an option that user can toggle
            write(file, "\n") 
            i += 1
        end
    end
end

### CONSTANT BEHAVIOUR FUNCTIONS ###
# Header
function writeHeader(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getHeader(outputData))
    end
end
getHeader(outputData::OutputData) = "Title: $(outputData.inputData.problemName)\nNodal Points: $(outputData.inputData.nodalPoints), Base Nodal Point Index: $(outputData.inputData.bottomPointIndex)\nNumber of different soil layers: $(outputData.inputData.soilLayers)\nIncrement depth(dx): $(outputData.inputData.dx)\n"
getHeaderValues(outputData::OutputData) = (outputData.inputData.problemName, outputData.inputData.nodalPoints, outputData.inputData.bottomPointIndex, outputData.inputData.soilLayers, outputData.inputData.dx)
####################################

### CHANGING BEHAVIOUR FUNCTIONS ###
# ModelOutputBehaviour
performWriteModelOutput(outputData::OutputData, path::String) = ModelBehaviour.writeModelOutput(getModelOutBehaviour(outputData), path)
performGetModelOutput(outputData::OutputData) = ModelBehaviour.getModelOutput(getModelOutBehaviour(outputData))
performGetModelValue(outputData::OutputData) = ModelBehaviour.getModelValue(getModelOutBehaviour(outputData))

# FoundationOutputBehaviour
performWriteFoundationOutput(outputData::OutputData, path::String) = FoundationBehaviour.writeFoundationOutput(getFoundationOutBehaviour(outputData), path)
performGetFoundationOutput(outputData::OutputData) = FoundationBehaviour.getFoundationOutput(getFoundationOutBehaviour(outputData))
performGetFoundationValue(outputData::OutputData) = FoundationBehaviour.getFoundationValue(getFoundationOutBehaviour(outputData))

# DisplacementInfoBehaviour
performWriteDisplacementOutput(outputData::OutputData, path::String) = DisplacementBehaviour.writeDisplacementOutput(getDisplacementInfoBehaviour(outputData), path)
performGetDisplacementOutput(outputData::OutputData) = DisplacementBehaviour.getDisplacementOutput(getDisplacementInfoBehaviour(outputData))
performGetDisplacementValue(outputData::OutputData) = DisplacementBehaviour.getDisplacementValue(getDisplacementInfoBehaviour(outputData))

# EquilibriumInfoBehaviour
performWriteEquilibriumOutput(outputData::OutputData, path::String) =  EquilibriumBehaviour.writeEquilibriumOutput(getEquilibriumInfoBehaviour(outputData), path)
performGetEquilibriumOutput(outputData::OutputData) = EquilibriumBehaviour.getEquilibriumOutput(getEquilibriumInfoBehaviour(outputData))
performGetEquilibriumValue(outputData::OutputData) = EquilibriumBehaviour.getEquilibriumValue(getEquilibriumInfoBehaviour(outputData))
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
# Get FoundationOutputBehaviour instance
function getFoundationOutBehaviour(outputData::OutputData)
    foundationOutBehaviour = 0
    if outputData.inputData.foundation == InputParser.RectangularSlab
        foundationOutBehaviour = FoundationBehaviour.RectangularSlabBehaviour()
    else
        foundationOutBehaviour = FoundationBehaviour.LongStripFootingBehaviour()
    end
    return foundationOutBehaviour
end
# Get DisplacementInfoBehaviour instance
function getDisplacementInfoBehaviour(outputData::OutputData)
    displacementInfoBehaviour = 0
    if outputData.inputData.outputIncrements == true
        displacementInfoBehaviour = DisplacementBehaviour.DisplacementEachDepthBehaviour()
    else
        displacementInfoBehaviour = DisplacementBehaviour.TotalDisplacementBehaviour()
    end
    return displacementInfoBehaviour
end
# Get EquilibriumInfoBehaviour instance
function getEquilibriumInfoBehaviour(outputData::OutputData)
    # !equilibriumMoistureProfile or NOpt = Saturated
    # Convert from enum to boolean. NOpt here is called leonardFrostModel.
    leonardFrostModel = (Int(outputData.inputData.model) == 1) ? true : false
    if !outputData.inputData.equilibriumMoistureProfile || leonardFrostModel
        return EquilibriumBehaviour.EquilibriumSaturatedBehaviour()
    else
        return EquilibriumBehaviour.EquilibriumHydrostaticBehaviour()
    end
end
####################################

end # module