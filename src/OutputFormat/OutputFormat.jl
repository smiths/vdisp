module OutputFormat

using PrettyTables

include("../InputParser.jl")
include("./ModelBehaviour.jl")
include("./FoundationBehaviour.jl")
include("./DisplacementBehaviour.jl")
include("./EquilibriumBehaviour.jl")
include("./ForcePointBehaviour.jl")
include("./CalculationBehaviour.jl")

using .InputParser
using .ModelBehaviour
using .FoundationBehaviour
using .DisplacementBehaviour
using .EquilibriumBehaviour
using .ForcePointBehaviour
using .CalculationBehaviour

export OutputData, writeOutput, writeDefaultOutput

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
        for f in order
            write(file, f(outputData))

            # Seperate each section with empty line
            # We can make this an option that user can toggle
            write(file, "\n") 
        end
    end
end
function writeDefaultOutput(outputData::OutputData, path::String)
    writeOutput([getHeader, performGetModelOutput, performGetFoundationOutput, getFoundationDepth, getSoilTable, getMaterialInfoTable, getDepthToGroundWaterTable, performGetDisplacementOutput, performGetEquilibriumOutput, performGetForcePointOutput, performGetCalculationOutput], outputData, path)
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

# Foundation Depth
function writeFoundationDepth(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getFoundationDepth(outputData))
    end
end
function getFoundationDepth(outputData::OutputData) 
    values = getFoundationDepthValues(outputData)
    return "Depth of Foundation: $(values[1])\nTotal Depth of Soil Profile: $(values[2])\n"
end
function getFoundationDepthValues(outputData::OutputData)
    inData = outputData.inputData
    # DEPF = DX*FLOAT(NBX-1)
    foundationDepth = inData.dx * float(inData.bottomPointIndex-1)
    # DEPPR = DX*FLOAT(NNP-1)
    totalDepth = inData.dx * float(inData.nodalPoints-1)
    return (foundationDepth, totalDepth)
end

# Soil Table 
function writeSoilTable(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getSoilTable(outputData))
    end
end
function getSoilTable(outputData::OutputData)
    values = getSoilTableValues(outputData)
    return pretty_table(String, values; header = ["Element", "Soil Layer Number"],tf = tf_markdown)
end
function getSoilTableValues(outputData::OutputData)
    inData = outputData.inputData
    values = [1 inData.soilLayerNumber[1]]
    for i=2:inData.elements
        values = vcat(values, [i inData.soilLayerNumber[i]])
    end
    return values
end

# Material Info Table
function writeMaterialInfoTable(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getMaterialInfoTable(outputData))
    end
end
function getMaterialInfoTable(outputData::OutputData)
    values = getMaterialInfoTableValues(outputData)
    return pretty_table(String, values; header = ["Material", "Specific Gravity", "Water Content(%)", "Void Ratio"],tf = tf_markdown)
end
function getMaterialInfoTableValues(outputData::OutputData)
    inData = outputData.inputData
    values = [1 inData.specificGravity[1] inData.waterContent[1] inData.voidRatio[1]]
    for i=2:inData.soilLayers
        values = vcat(values, [i inData.specificGravity[i] inData.waterContent[i] inData.voidRatio[i]])
    end
    return values
end

# Depth to Ground Water Table
function writeDepthToGroundWaterTable(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getDepthToGroundWaterTable(outputData))
    end
end
getDepthToGroundWaterTable(outputData::OutputData) = "Depth to Ground Water Table: $(getDepthToGroundWaterTableValue(outputData))\n"
getDepthToGroundWaterTableValue(outputData::OutputData) = outputData.inputData.depthGroundWaterTable
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

# ForcePointBehaviour
performWriteForcePointOutput(outputData::OutputData, path::String) = ForcePointBehaviour.writeForcePointOutput(getForcePointOutputBehaviour(outputData), path)
performGetForcePointOutput(outputData::OutputData) = ForcePointBehaviour.getForcePointOutput(getForcePointOutputBehaviour(outputData))
performGetForcePointValue(outputData::OutputData) = ForcePointBehaviour.getForcePointValue(getForcePointOutputBehaviour(outputData))

# CalculationOutputBehaviour
performWriteCalculationOutput(outputData::OutputData, path::String) = CalculationBehaviour.writeCalculationOutput(getCalculationOutputBehaviour(outputData), path)
performGetCalculationOutput(outputData::OutputData) = CalculationBehaviour.getCalculationOutput(getCalculationOutputBehaviour(outputData))
performGetCalculationValue(outputData::OutputData) = CalculationBehaviour.getCalculationValue(getCalculationOutputBehaviour(outputData))
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
# Get ForcePointOutputBehaviour instance
function getForcePointOutputBehaviour(outputData::OutputData)
    center = outputData.inputData.center
    if center 
        return CenterForceBehaviour()
    end
    foundation = outputData.inputData.foundation
    return EdgeForceBehaviour(foundation)
end
# Get CalculationOutputBehaviour instance
function getCalculationOutputBehaviour(outputData::OutputData)
    inputData = outputData.inputData
    if string(inputData.model) == string(InputParser.ConsolidationSwell)
        return ConsolidationSwellCalculationBehaviour(inputData.nodalPoints)
    elseif string(inputData.model) == string(InputParser.LeonardFrost)
        return LeonardFrostCalculationBehaviour(inputData.nodalPoints)
    elseif string(inputData.model) == string(InputParser.Schmertmann)
        return SchmertmannCalculationBehaviour(inputData.nodalPoints)
    elseif string(inputData.model) == string(InputParser.CollapsibleSoil)
        return CollapsibleSoilCalculationBehaviour(inputData.nodalPoints)
    else
        return SchmertmannElasticCalculationBehaviour(inputData.nodalPoints)
    end
end
####################################

end # module