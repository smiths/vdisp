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

export OutputData, writeOutput, writeDefaultOutput, getData

# Output Data Struct
struct OutputData
    inputData::InputData
    
    # Generates OutputData from input file at path
    OutputData(path::String) = new(InputData(path))

    # Generates OutputData from ConsolidationSwell data collected from QML GUI
    OutputData(problemName::String, foundationType::String, materialCount::Int32, dx::Array{Float64}, soilLayerNumbers::Array{Int32}, nodalPoints::Int32, elements::Int32, materialNames::Array{String}, specificGravity::Array{Float64}, voidRatio::Array{Float64}, waterContent::Array{Float64}, subdivisions::Array{Int32}, swellPressure::Array{Float64}, swellIndex::Array{Float64}, compressionIndex::Array{Float64}, maxPastPressure::Array{Float64}, foundationIndex::Int32, depthGroundWaterTable::Float64, saturatedAboveWaterTable::Bool, outputIncrements::Bool, appliedPressure::Float64, foundationLength::Float64, foundationWidth::Float64, center::Bool, heaveActive::Float64, heaveBegin::Float64, totalDepth::Float64, foundationDepth::Float64, units::Int32) = new(InputData(problemName, foundationType, materialCount, dx, soilLayerNumbers, nodalPoints, elements, materialNames, specificGravity, voidRatio, waterContent, subdivisions, swellPressure, swellIndex, compressionIndex, maxPastPressure, foundationIndex, depthGroundWaterTable, saturatedAboveWaterTable, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, heaveActive, heaveBegin, totalDepth, foundationDepth, units))
    
    # Generates OutputData from Schmertmann data collected from QML GUI
    OutputData(problemName::String, foundationType::String, materialCount::Int32, dx::Array{Float64}, soilLayerNumbers::Array{Int32}, nodalPoints::Int32, elements::Int32, materialNames::Array{String}, specificGravity::Array{Float64}, voidRatio::Array{Float64}, waterContent::Array{Float64}, subdivisions::Array{Int32}, conePenetration::Array{Float64}, foundationIndex::Int32, depthGroundWaterTable::Float64, saturatedAboveWaterTable::Bool, outputIncrements::Bool, appliedPressure::Float64, foundationLength::Float64, foundationWidth::Float64, center::Bool, heaveActive::Float64, heaveBegin::Float64, totalDepth::Float64, foundationDepth::Float64, timeAfterConstruction::Int32, units::Int32) = new(InputData(problemName, foundationType, materialCount, dx, soilLayerNumbers, nodalPoints, elements, materialNames, specificGravity, voidRatio, waterContent, subdivisions, conePenetration, foundationIndex, depthGroundWaterTable, saturatedAboveWaterTable, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, heaveActive, heaveBegin, totalDepth, foundationDepth, timeAfterConstruction, units))
    
    # Generates OutputData from SchmertmannElastic data collected from QML GUI
    OutputData(problemName::String, foundationType::String, materialCount::Int32, dx::Array{Float64}, soilLayerNumbers::Array{Int32}, nodalPoints::Int32, elements::Int32, materialNames::Array{String}, specificGravity::Array{Float64}, voidRatio::Array{Float64}, waterContent::Array{Float64}, subdivisions::Array{Int32}, foundationIndex::Int32, depthGroundWaterTable::Float64, saturatedAboveWaterTable::Bool, outputIncrements::Bool, appliedPressure::Float64, foundationLength::Float64, foundationWidth::Float64, center::Bool, heaveActive::Float64, heaveBegin::Float64, totalDepth::Float64, foundationDepth::Float64, elasticModulus::Array{Float64}, timeAfterConstruction::Int32, units::Int32) = new(InputData(problemName, foundationType, materialCount, dx, soilLayerNumbers, nodalPoints, elements, materialNames, specificGravity, voidRatio, waterContent, subdivisions, foundationIndex, depthGroundWaterTable, saturatedAboveWaterTable, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, heaveActive, heaveBegin, totalDepth, foundationDepth, elasticModulus, timeAfterConstruction, units))
end

"""
    writeOutput(order::Array{Function}, outputData::OutputData, path::String, sep::String="\n")

This function can be used to write data from an `OutputData` instance to file at `path` in a
custom defined order by passing in an `Array` of functions called `order`. The return value of 
these functions is written to the file, and each function is written in order. The output of each
function is separated by `sep`, which is set to the newline character by default.

> Note: It is recommended that each function returns a `String`, and that this `String` ends in a newline character

This function is currently called in `VDisp` by the `writeDefaultOutput()` function, which passes in 
the default order of functions who's values are written to the output file. These functions are (in order):

* getHeader
* performGetModelOutput 
* performGetFoundationOutput 
* getFoundationDepth 
* getSoilTable 
* getMaterialInfoTable 
* getDepthToGroundWaterTable 
* performGetDisplacementOutput 
* performGetEquilibriumOutput 
* performGetForcePointOutput 
* performGetCalculationOutput

> Functions named "perform<function>" are "changing behaviour" functions. These functions return different things based on the outputData instance passed in. All modules named "<Info>Behaviour.jl" deal with this behaviour. See the [Design.pdf](https://github.com/smiths/vdisp/blob/main/docs/Design/Design.pdf) for more information on this design pattern.

# Example Use Case

If a user wants to include timestamps at the top of each file, and wants to get rid of the sections that are repeats
of the input data, they can first define a function called `getDate()` which returns the timestamp in whatever format they 
please. They can then call `writeOutput([getData, performGetCalculationOutput], outputData, path)`. This will output a file
with only the timestamp, and output information which is given by `performGetCalculationOutput`.
"""
function writeOutput(order::Array{Function}, outputData::OutputData, path::String, sep::String="\n")
    # w - overwrite file contents 
    open(path, "w") do file
        for f in order
            write(file, f(outputData))
            # Seperate each section with user defined delimeter
            write(file, sep) 
        end
    end
end

"""
    writeDefaultOutput(outputData::OutputData, path::String)

Writes the outputs in the default format which includes all the input data for traceability
purposes, and all the outputs after. By default, it also writes effective stress values to a 
file with the same name but different file extension (".eff.dat"). For more info on the effective
stress outputs, see `writeEffectiveStress` docs.
"""
function writeDefaultOutput(outputData::OutputData, path::String)
    # Write all content to output file in default order
    writeOutput([getHeader, performGetModelOutput, performGetFoundationOutput, getFoundationDepth, getSoilTable, getMaterialInfoTable, getDepthToGroundWaterTable, performGetDisplacementOutput, performGetEquilibriumOutput, performGetForcePointOutput, performGetCalculationOutput], outputData, path)
    
    # Path of effective stress file is <file>.eff.dat
    effPath = path[1:end-3]*"eff.dat"
    # Write effective stress values to file at effPath
    writeEffectiveStresses(outputData, effPath)
end


### CONSTANT BEHAVIOUR FUNCTIONS ###
# Header
function writeHeader(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getHeader(outputData))
    end
end
function getHeader(outputData::OutputData)
    inData = outputData.inputData
    
    headerString = "Title: $(inData.problemName)\n\n"
    
    incrementTable = []
    for (i,x) in enumerate(inData.dx)
        if size(incrementTable)[1] == 0
            incrementTable = [i inData.materialNames[i] x]
        else
            incrementTable = vcat(incrementTable, [i inData.materialNames[i] x])
        end
    end
    headerString *= pretty_table(String, incrementTable; header = ["Material", "Material Name", "Increment Depth(dx)"],tf = tf_markdown)
    headerString *= "\n"
end
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
    return (inData.foundationDepth, inData.totalDepth)
end

# Soil Table 
function writeSoilTable(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getSoilTable(outputData))
    end
end
function getSoilTable(outputData::OutputData)
    values = getSoilTableValues(outputData)
    return pretty_table(String, values; header = ["Soil Layer", "Material", "Material Name"],tf = tf_markdown)
end
function getSoilTableValues(outputData::OutputData)
    inData = outputData.inputData
    values = [1 inData.soilLayerNumber[1] inData.materialNames[inData.soilLayerNumber[1]]]
    for i=2:inData.elements
        values = vcat(values, [i inData.soilLayerNumber[i] inData.materialNames[inData.soilLayerNumber[i]]])
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
    return pretty_table(String, values; header = ["Material", "Material Name", "Specific Gravity", "Water Content(%)", "Void Ratio"],tf = tf_markdown)
end
function getMaterialInfoTableValues(outputData::OutputData)
    inData = outputData.inputData
    values = [1 inData.materialNames[1] inData.specificGravity[1] inData.waterContent[1] inData.voidRatio[1]]
    for i=2:inData.soilLayers
        values = vcat(values, [i inData.materialNames[i] inData.specificGravity[i] inData.waterContent[i] inData.voidRatio[i]])
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
performGetCalculationValue(outputData) = CalculationBehaviour.getCalculationValue(getCalculationOutputBehaviour(outputData))

"""
    writeEffectiveStresses(outputData, outputPath::String)

Writes table of effective stress values of each soil *sub*layer before and after applying the foundation load
to file at `outputPath`.

> VDisp calls this function from within the `writeDefaultOutput()` function. Thus, by default every VDisp output includes a **separate** file which displays the effective stress values. This file has the same filepath and name as the normal output file, but has the ".eff.dat" extension rather than ".dat".

"""
function writeEffectiveStresses(outputData, outputPath::String)
    # Get values from Behaviour instances getValue() function
    vals = performGetCalculationValue(outputData)
    
    # Arrays P and PP are always first two values return by any behaviour instances getValue() function
    P = vals[1]
    PP = vals[2]
    
    # Create Stresses Table
    stressTable::Array{Union{Int, Float64}} = []
    for i=1:size(P)[1]
        if size(stressTable)[1] == 0
            stressTable = [Int(i) PP[i] P[i]]
        else
            stressTable = vcat(stressTable, [Int(i) PP[i] P[i]])
        end
    end

    # Get units
    pressureUnit = (outputData.inputData.units == Int(InputParser.Imperial)) ? "tsf" : "Pa"

    # Create Table
    table = pretty_table(String, stressTable; header = ["Soil Layer", "Effective Stress of Soil ($(pressureUnit))", "Effective Stress After Placing Load ($(pressureUnit))"],tf = tf_markdown)

    # Write Table
    open(outputPath, "w") do file
        write(file, "Effective Stresses of Soil Profile\n\n" * table)
    end
end
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
    return EdgeForceBehaviour(string(foundation))
end

# Get CalculationOutputBehaviour instance
function getCalculationOutputBehaviour(outputData)
    inputData = outputData.inputData
    
    effectiveStressValues = [inputData.nodalPoints, string(inputData.model), inputData.dx, inputData.soilLayerNumber, inputData.specificGravity, inputData.waterContent, inputData.voidRatio, inputData.depthGroundWaterTable, inputData.equilibriumMoistureProfile]
    surchargePressureValues = [inputData.bottomPointIndex, inputData.appliedPressure, string(inputData.foundation), inputData.foundationLength, inputData.foundationWidth, inputData.center]
    
    if string(inputData.model) == string(InputParser.ConsolidationSwell)
        calcValues = [inputData.heaveActiveZoneDepth, inputData.groundToHeaveDepth, inputData.swellPressure, inputData.swellIndex, inputData.compressionIndex, inputData.maxPastPressure, inputData.outputIncrements, inputData.elements, inputData.units, inputData.materialNames]
        return ConsolidationSwellCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues)
    elseif string(inputData.model) == string(InputParser.LeonardFrost)
        return LeonardFrostCalculationBehaviour(effectiveStressValues, surchargePressureValues)
    elseif string(inputData.model) == string(InputParser.Schmertmann)
        calcValues = [inputData.elements, inputData.timeAfterConstruction, inputData.conePenetrationResistance, inputData.outputIncrements, inputData.units,  inputData.materialNames]
        return SchmertmannCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues)
    elseif string(inputData.model) == string(InputParser.CollapsibleSoil)
        return CollapsibleSoilCalculationBehaviour(effectiveStressValues, surchargePressureValues)
    else
        calcValues = [inputData.elements, inputData.timeAfterConstruction, inputData.conePenetrationResistance, inputData.outputIncrements, inputData.elasticModulus, inputData.units,  inputData.materialNames]
        return SchmertmannElasticCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues)
    end
end

####################################

"""
Creates OutputData instance from given path and returns instance
of OutputData and its corresponding instance of InputData as a tuple
"""
function getData(path::String)
    outputData = 0
    try
        outputData = OutputData(path)
    catch e
        id = 0
        try 
            id = e.id
        catch err 
            println("Unexpected Error! Skipping Tests!")
            throw(ArgumentError("Bad Input File"))
        end
        if id == Int(InputParser.ParsingErrorId)
            println("Error! Skipping Tests!")
        elseif id == Int(InputParser.SoilNumberErrorId)
            println("Error: Invalid input file!")
            println("\t>Line $(e.line): Soil layer number must be larger than previous one!") 
        else
            println("Unexpected Error! Skipping Tests!")
        end
        throw(ArgumentError("Bad Input File"))
    end
    return (outputData, outputData.inputData)
end

end # module