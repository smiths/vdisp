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
    writeOutput(order::Array{Function}, outputData::OutputData, path::String, sep::String="\\n")

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

More info on these functions can be found below.

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
"""
    getHeader(outputData::OutputData)

Returns `String` value stating the title of the problem, and depth increments of each layer.
"""
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
"""
    getHeaderValues(outputData::OutputData)

Returns a `Tuple` containing the ordered pair `(problemName::Float64, soilLayers::Int, dx::Array{Float64})`.
"""
getHeaderValues(outputData::OutputData) = (outputData.inputData.problemName, outputData.inputData.soilLayers, outputData.inputData.dx)

# Foundation Depth
function writeFoundationDepth(outputData::OutputData, path::String)
    open(path, "a") do file
        write(file, getFoundationDepth(outputData))
    end
end
"""
    getFoundationDepth(outputData::OutputData)

Returns `String` value stating depth of foundation and total depth of the soil profile.
"""
function getFoundationDepth(outputData::OutputData) 
    values = getFoundationDepthValues(outputData)
    return "Depth of Foundation: $(values[1])\nTotal Depth of Soil Profile: $(values[2])\n"
end
"""
    getFoundationDepthValues(outputData::OutputData)

Returns a `Tuple` containing the ordered pair `(foundationDepth::Float64, totalDepth::Float64)`.
"""
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
"""
    getSoilTable(outputData::OutputData)

Returns `String` value containing a table which shows each soil sublayer, its material and material name.

> Uses `PrettyTables.jl` to convert `Array{Union{String, Int}, 3}` given by `getMaterialInfoTable()` into a `String`
"""
function getSoilTable(outputData::OutputData)
    values = getSoilTableValues(outputData)
    return pretty_table(String, values; header = ["Soil Layer", "Material", "Material Name"],tf = tf_markdown)
end
"""
    getSoilTableValues(outputData::OutputData)

Returns `Array{Union{String, Float64, Int}, 3}` value. This array represents the following table, with an entry for each soil sublayer:

| Soil Layer | Material | Material Name |
|:----------:|:--------:|:-------------:|
|     x      |    x     |       x       |
"""
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
"""
    getMaterialInfoTable(outputData::OutputData)

Returns `String` value containing a table which shows each material, its name, and properties (specific gravity, void ratio, water content).

> Uses `PrettyTables.jl` to convert `Array{Union{String, Float64, Int}, 5}` given by `getMaterialInfoTable()` into a `String`
"""
function getMaterialInfoTable(outputData::OutputData)
    values = getMaterialInfoTableValues(outputData)
    return pretty_table(String, values; header = ["Material", "Material Name", "Specific Gravity", "Water Content(%)", "Void Ratio"],tf = tf_markdown)
end
"""
    getMaterialInfoTableValues(outputData::OutputData)

Returns `Array{Union{String, Float64, Int}, 5}` value. This array represents the following table, with an entry for each material:

| Material | Material Name | Specific Gravity | Water Content | Void Ratio |
|:--------:|:-------------:|:----------------:|:-------------:|:----------:|
|    x     |       x       |         x        |       x       |      x     |
"""
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
"""
    getDepthToGroundWaterTable(outputData::OutputData)

Returns `String` value stating the ground water table depth
"""
getDepthToGroundWaterTable(outputData::OutputData) = "Depth to Ground Water Table: $(getDepthToGroundWaterTableValue(outputData))\n"
"""
    getDepthToGroundWaterTableValue(outputData::OutputData)

Returns `Float64` value of the depth to the ground water table
"""
getDepthToGroundWaterTableValue(outputData::OutputData) = outputData.inputData.depthGroundWaterTable
####################################

### CHANGING BEHAVIOUR FUNCTIONS ###
# ModelOutputBehaviour
performWriteModelOutput(outputData::OutputData, path::String) = ModelBehaviour.writeModelOutput(getModelOutBehaviour(outputData), path)
"""
    performGetModelOutput(outputData::OutputData)

Returns the `String` returned by the `getOutput()` function of the `ModelBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getModelOutBehaviour()` function to get the specific instance of `ModelBehaviour.jl` related to the `outputData`.
"""
performGetModelOutput(outputData::OutputData) = ModelBehaviour.getModelOutput(getModelOutBehaviour(outputData))
"""
    performGetModelValue(outputData::OutputData)

Returns the `Model` value returned by the `getValue()` function of the `ModelBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getModelOutBehaviour()` function to get the specific instance of `ModelBehaviour.jl` related to the `outputData`.

* ConsolidationSwell
* Schmertmann
* SchmertmannElastic
"""
performGetModelValue(outputData::OutputData) = ModelBehaviour.getModelValue(getModelOutBehaviour(outputData))

# FoundationOutputBehaviour
performWriteFoundationOutput(outputData::OutputData, path::String) = FoundationBehaviour.writeFoundationOutput(getFoundationOutBehaviour(outputData), path)
"""
    performGetFoundationOutput(outputData::OutputData)

Returns the `String` returned by the `getOutput()` function of the `FoundationBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getFoundationOutBehaviour()` function to get the specific instance of `FoundationBehaviour.jl` related to the `outputData`.
"""
performGetFoundationOutput(outputData::OutputData) = FoundationBehaviour.getFoundationOutput(getFoundationOutBehaviour(outputData))
"""
    performGetFoundationValue(outputData::OutputData)

Returns the `Foundation` value returned by the `getValue()` function of the `FoundationBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getFoundationOutBehaviour()` function to get the specific instance of `FoundationBehaviour.jl` related to the `outputData`.

* `RectangularSlab`
* `LongStripFooting`
"""
performGetFoundationValue(outputData::OutputData) = FoundationBehaviour.getFoundationValue(getFoundationOutBehaviour(outputData))

# DisplacementInfoBehaviour
performWriteDisplacementOutput(outputData::OutputData, path::String) = DisplacementBehaviour.writeDisplacementOutput(getDisplacementInfoBehaviour(outputData), path)
"""
    performGetDisplacementOutput(outputData::OutputData)

Returns the `String` returned by the `getOutput()` function of the `DisplacementBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getDisplacementInfoBehaviour()` function to get the specific instance of `DisplacementBehaviour.jl` related to the `outputData`.
"""
performGetDisplacementOutput(outputData::OutputData) = DisplacementBehaviour.getDisplacementOutput(getDisplacementInfoBehaviour(outputData))
"""
    performGetDisplacementValue(outputData::OutputData)

Returns the `boolean` value returned by the `getValue()` function of the `DisplacementBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getDisplacementInfoBehaviour()` function to get the specific instance of `DisplacementBehaviour.jl` related to the `outputData`.

* `true` - Output increments
* `false` - Output total displacements only
"""
performGetDisplacementValue(outputData::OutputData) = DisplacementBehaviour.getDisplacementValue(getDisplacementInfoBehaviour(outputData))

# EquilibriumInfoBehaviour
performWriteEquilibriumOutput(outputData::OutputData, path::String) =  EquilibriumBehaviour.writeEquilibriumOutput(getEquilibriumInfoBehaviour(outputData), path)
"""
    performGetEquilibriumOutput(outputData::OutputData)

Returns the `String` returned by the `getOutput()` function of the `EquilibriumBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getEquilibriumInfoBehaviour()` function to get the specific instance of `EquilibriumBehaviour.jl` related to the `outputData`.
"""
performGetEquilibriumOutput(outputData::OutputData) = EquilibriumBehaviour.getEquilibriumOutput(getEquilibriumInfoBehaviour(outputData))
"""
    performGetEquilibriumValue(outputData::OutputData)

Returns the `boolean` value returned by the `getValue()` function of the `EquilibriumBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getEquilibriumInfoBehaviour()` function to get the specific instance of `EquilibriumBehaviour.jl` related to the `outputData`.

* `true` - Saturation above ground water table
* `false` - Hydrostatic profile above ground water table
"""
performGetEquilibriumValue(outputData::OutputData) = EquilibriumBehaviour.getEquilibriumValue(getEquilibriumInfoBehaviour(outputData))

# ForcePointBehaviour
performWriteForcePointOutput(outputData::OutputData, path::String) = ForcePointBehaviour.writeForcePointOutput(getForcePointOutputBehaviour(outputData), path)
"""
    performGetForcePointOutput(outputData::OutputData)

Returns the `String` returned by the `getOutput()` function of the `ForcePointBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getForcePointOutputBehaviour()` function to get the specific instance of `ForcePointBehaviour.jl` related to the `outputData`.
"""
performGetForcePointOutput(outputData::OutputData) = ForcePointBehaviour.getForcePointOutput(getForcePointOutputBehaviour(outputData))
"""
    performGetForcePointValue(outputData::OutputData)

Returns the `boolean` value returned by the `getValue()` function of the `ForcePointBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getForcePointOutputBehaviour()` function to get the specific instance of `ForcePointBehaviour.jl` related to the `outputData`.

* `true` - Force applied at center of foundation
* `false` - Force applied at corner or edge
"""
performGetForcePointValue(outputData::OutputData) = ForcePointBehaviour.getForcePointValue(getForcePointOutputBehaviour(outputData))

# CalculationOutputBehaviour
performWriteCalculationOutput(outputData::OutputData, path::String) = CalculationBehaviour.writeCalculationOutput(getCalculationOutputBehaviour(outputData), path)

"""
    performGetCalculationOutput(outputData::OutputData)

Returns the `String` returned by the `getOutput()` function of the `CalculationBehaviour` implementation corresponding to the model used in the `outputData` struct. Uses `getCalculationOutputBehaviour()` function to get the specific instance of `CalculationBehaviour.jl` related to the `outputData`.
"""
performGetCalculationOutput(outputData::OutputData) = CalculationBehaviour.getCalculationOutput(getCalculationOutputBehaviour(outputData))

"""
    performGetCalculationValue(outputData)

Returns the `Tuple` returned by the `getValue()` function of the `CalculationBehaviour` implementation corresponding to the model user in the `outputData` struct. 
Uses `getCalculationOutputBehaviour()` function to get the specific instance of `CalculationBehaviour.jl` related to the `outputData`.

# Tuple Contents

Depending on the model of the calculations, `getValue()` returns a `Tuple` containing different info. This info is specified below:

* **Consolidation / Swell**: (P::Array{Float64}, PP::Array{Float64}, heaveAboveFoundationTable::Array{Union{Int, Float64}, 4}, heaveBelowFoundationTable::Array{Union{Int, Float64}, 4}, Δh1::Float64, Δh2::Float64, Δh::Float64)
    - `P`: Array of effective stresses of each soil sublayer *after* applying foundational forces.
    - `PP`:  Array of effective stresses of each soil sublayer *before* applying foundational forces.
    - `heaveAboveFoundationTable`: Table containing heave contribution, depth and excess pore pressure values of each soil sublayer *above* the foundation.
    - `heaveBelowFoundationTable`: Table containing heave contribution, depth and excess pore pressure values of each soil sublayer *below* the foundation.
    - `Δh1`: total heave contribution *above* foundation.
    - `Δh2`: total heave contribution *below* foundation.
    - `Δh`: total heave contribution of soil profile.

* **Schmertmann**: (P::Array{Float64}, PP::Array{Float64}, settlementTable::Array{Union{Int, Float64}, 3}, Δh::Float64)
    - `P`: Array of effective stresses of each soil sublayer *after* applying foundational forces.
    - `PP`:  Array of effective stresses of each soil sublayer *before* applying foundational forces.
    - `settlementTable`: Table containing settlement vs depth info for each soil sublayer.
    - `Δh`: total settlement of soil profile.

* **Schmertmann Elastic**: (P::Array{Float64}, PP::Array{Float64}, settlementTable::Array{Union{Int, Float64}, 3}, Δh::Float64)
    - `P`: Array of effective stresses of each soil sublayer *after* applying foundational forces.
    - `PP`:  Array of effective stresses of each soil sublayer *before* applying foundational forces.
    - `settlementTable`: Table containing settlement vs depth info for each soil sublayer.
    - `Δh`: total settlement of soil profile.

"""
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
"""
    getModelOutBehaviour(outputData::OutputData)

Returns specific implementation of `ModelOutBehaviour` given an instance of
the `OutputData` struct.

* `outputData.inputData.model == ConsolidationSwell`: returns `ConsolidationSwellBehaviour` 
* `outputData.inputData.model == Schmertmann`: returns `SchmertmannBehaviour` 
* `outputData.inputData.model == SchmertmannElastic`: returns `SchmertmannElasticBehaviour` 
"""
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
"""
    getFoundationOutBehaviour(outputData::OutputData)

Returns specific implementation of `FoundationBehaviour` given an instance of
the `OutputData` struct.

* `outputData.inputData.foundation == RectangularSlab`: returns `RectangularSlabBehaviour` 
* `outputData.inputData.foundation == LongStripFooting`: returns `LongStripFootingBehaviour` 
"""
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
"""
    getDisplacementInfoBehaviour(outputData::OutputData)

Returns specific implementation of `DisplacementBehaviour` given an instance of
the `OutputData` struct.

* `outputData.inputData.outputIncrements`: returns `DisplacementEachDepthBehaviour` 
* `!outputData.inputData.outputIncrements`: returns `TotalDisplacementBehaviour` 
"""
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
"""
    getEquilibriumInfoBehaviour(outputData::OutputData)

Returns specific implementation of `EquilibriumBehaviour` given an instance of
the `OutputData` struct.

* `outputData.inputData.equilibriumMoistureProfile`: returns `EquilibriumSaturatedBehaviour` 
* `!outputData.inputData.equilibriumMoistureProfile`: returns `EquilibriumHydrostaticBehaviour` 
"""
function getEquilibriumInfoBehaviour(outputData::OutputData)
    # !equilibriumMoistureProfile or NOpt = Saturated  (From original VDispl)
    # Convert from enum to boolean. NOpt here is called leonardFrostModel.  (We don't actually use LeonardFrost in VDisp. Left for future developers)
    leonardFrostModel = (Int(outputData.inputData.model) == 1) ? true : false
    if !outputData.inputData.equilibriumMoistureProfile || leonardFrostModel
        return EquilibriumBehaviour.EquilibriumSaturatedBehaviour()
    else
        return EquilibriumBehaviour.EquilibriumHydrostaticBehaviour()
    end
end

# Get ForcePointOutputBehaviour instance
"""
    getForcePointOutputBehaviour(outputData::OutputData)

Returns specific implementation of `ForcePointBehaviour` given an instance of
the `OutputData` struct.

* `outputData.inputData.center`: returns `CenterForceBehaviour` 
* `!outputData.inputData.center`: returns `EdgeForceBehaviour` 
"""
function getForcePointOutputBehaviour(outputData::OutputData)
    center = outputData.inputData.center
    if center 
        return CenterForceBehaviour()
    end
    foundation = outputData.inputData.foundation
    return EdgeForceBehaviour(string(foundation))
end

# Get CalculationOutputBehaviour instance
"""
    getCalculationOutputBehaviour(outputData::OutputData)

Returns specific implementation of `CalculationBehaviour` given an instance of
the `OutputData` struct.

* `outputData.inputData.model == ConsolidationSwell`: returns `ConsolidationSwellCalculationBehaviour` 
* `outputData.inputData.model == Schmertmann`: returns `SchmertmannCalculationBehaviour` 
* `outputData.inputData.model == SchmertmannElastic`: returns `SchmertmannElasticCalculationBehaviour` 
"""
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