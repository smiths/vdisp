"""
    getEffectiveStress(), getSurchargePressure(), schmertmannApproximation() and getValue() functions 
adopt code from original FORTRAN program VDispl, found on p.180 of this document:
https://www.publications.usace.army.mil/Portals/76/Publications/EngineerManuals/EM_1110-1-1904.pdf
"""

module CalculationBehaviour

using PrettyTables

include("../InputParser.jl")
using .InputParser

export CalculationOutputBehaviour, ConsolidationSwellCalculationBehaviour, LeonardFrostCalculationBehaviour, SchmertmannCalculationBehaviour, SchmertmannElasticCalculationBehaviour, CollapsibleSoilCalculationBehaviour, writeCalculationOutput, getCalculationOutput, getCalculationValue, getEffectiveStress, getSurchargePressure, getValue, schmertmannApproximation, toFixed

MIN_DX = 0.01

@doc raw"""
    toFixed(n::Float64, digits::Int)

Returns `String` of `n` rounded and displayed to `digits` digits after decimal point. If all data would be lost to rounding,
returns `n` in scientific notation

# Examples

```
julia> toFixed(54.5, 4)
"54.5000"
```

```
julia> toFixed(54.51999, 2)
"54.52"
```

```
julia> toFixed(0.0000054, 3)
"5.400e-6"
```

```
julia> toFixed(0.00024234, 3)
"2.423e-4"
```

This function is used by `VDisp` to round calculation results before writing tables to the output file.
"""
function toFixed(n::Float64, digits::Int)::String
    # Since we later check if rounding n makes us lose all data
    # first check if the original value was 0.
    if n == 0
        return "0."*"0"^digits
    end
    
    rounded = round(n, digits=digits)
    
    if rounded == 0  # If we lost all data to rounding, convert to scientific notation
        s = string(n)
        if 'e' in s  # string() automatically converted it to scientific notation
            # Split number and exponent
            num, exp = split(s, "e")  
            # Parse exponent as Int (and make it positive)
            e = -parse(Int, exp)  
            # Bring decimal point past first non-zero digit
            newNum = n * 10^e  

            # Add extra trailing 0s
            s = string(newNum) * "0"^digits  
            # Grab everything before the decimal and the desired amount of digits past the decimal
            index = length(split(s, ".")[1]) + digits  


            # Return number in scientific notation
            return s[1:index+1] * "e-$e" 
        else  # string() didn't convert to scientific
            # Split number around the decimal point
            a, b = split(s, ".")

            # Find how many places we need to move over the decimal
            exp = 1
            while b[exp] == '0'
                exp += 1
            end

            # Move over decimal until first number is non-zero
            newNum = n * 10^exp

            # Add extra trailing 0s
            s = string(newNum) * "0"^digits
            # Grab everything before the decimal and the desired amount of digits past the decimal
            index = length(split(s, ".")[1]) + digits
            
            # Return number in scientific notation
            return s[1:index+1] * "e-$(exp)" 
        end 
    end
    
    # Else if data was not lost
    s = string(rounded)
    if !('e' in s)  # If value wasn't big enough to be given scientific notation
        # Pad with zeros
        s *= "0"^digits
        # Grab everything before the decimal and the desired amount of digits past the decimal
        index = length(split(s, ".")[1]) + digits
    
        # Return string up until desired index
        return s[1:index+1]
    else
        num, exp = split(s, 'e')

        # Pad string before the exponent part with 0s
        num = num * "0"^digits

        # Grab everything before the decimal and the desired amount of digits past the decimal
        index = length(split(num, ".")[1]) + digits
        
        # Return number in scientific notation
        return num[1:index+1] * "e+$(exp)"
    end
end

### CalculationOutputBehaviour interface ##############
abstract type CalculationOutputBehaviour end
function writeCalculationOutput(calcBehaviour::CalculationOutputBehaviour, path::String)
    open(path, "a") do file
        write(file, getCalculationOutput(calcBehaviour))
    end
end
function getCalculationOutput(calcBehaviour::CalculationOutputBehaviour)
    return getOutput(calcBehaviour)*"\n"
end
function getCalculationValue(calcBehaviour::CalculationOutputBehaviour)
    return getValue(calcBehaviour)
end
#######################################################

### ConsolidationSwellCalculationBehaviour "class" ####
struct ConsolidationSwellCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Array{Float64}
    soilLayerNumber::Array{Int}
    specificGravity::Array{Float64}
    waterContent::Array{Float64}
    voidRatio::Array{Float64}
    depthGroundWaterTable::Float64
    equilibriumMoistureProfile::Bool
    bottomPointIndex::Int
    appliedPressure::Float64
    foundation::String
    foundationLength::Float64
    foundationWidth::Float64
    center::Bool
    heaveActiveZoneDepth::Float64
    groundToHeaveDepth::Float64
    swellPressure::Array{Float64}
    swellIndex::Array{Float64}
    compressionIndex::Array{Float64}
    maxPastPressure::Array{Float64}
    outputIncrements::Bool
    elements::Int
    units::Int
    materialNames::Array{String}

    ConsolidationSwellCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6],calcValues[1],calcValues[2],calcValues[3],calcValues[4],calcValues[5],calcValues[6],calcValues[7], calcValues[8], calcValues[9], calcValues[10])
end
function getOutput(behaviour::ConsolidationSwellCalculationBehaviour)
    # getValue does the calculations
    P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, Δh1, Δh2, Δh = getValue(behaviour)
    
    out = ""

    # Output Material Properties Table 
    materialCount = size(behaviour.materialNames)[1]
    materialPropertiesTable = [1 behaviour.materialNames[1] behaviour.swellPressure[1] behaviour.swellIndex[1] behaviour.compressionIndex[1] behaviour.maxPastPressure[1]]
    for i=2:materialCount
        materialPropertiesTable = vcat(materialPropertiesTable, [i behaviour.materialNames[i] behaviour.swellPressure[i] behaviour.swellIndex[i] behaviour.compressionIndex[i] behaviour.maxPastPressure[i]])
    end

    pressureUnit = (behaviour.units == Int(InputParser.Imperial)) ? "tsf" : "KPa"
    
    out *= "Material Properties:\n\n"
    out *= pretty_table(String, materialPropertiesTable; header = ["Material", "Material Name", "Swell Pressure ($(pressureUnit))", "Swell Index", "Compression Index", "Preconsolidation Pressure ($(pressureUnit))"],tf = tf_markdown)
    out *= "\n"

    depthUnit = (behaviour.units == Int(InputParser.Imperial)) ? "ft" : "m"

    # Output tables if user selected "Output Increments" option
    if behaviour.outputIncrements
        if size(heaveAboveFoundationTable)[1] > 0
            # Copy calculations table to new table with values rounded to fixed number of digits
            heaveAboveFoundationTableRows, heaveAboveFoundationTableCols = size(heaveAboveFoundationTable)
            heaveAbove = Array{Union{Int, Float64, String}}(undef, heaveAboveFoundationTableRows, heaveAboveFoundationTableCols)
            for i=1:heaveAboveFoundationTableRows
                for j=1:heaveAboveFoundationTableCols
                    if j == 1   # Make sure Material Index is Int
                        heaveAbove[i, j] = Int(heaveAboveFoundationTable[i, j])
                    elseif j == 2  # Round Depth values to 3 decimal places
                        heaveAbove[i, j] = toFixed(heaveAboveFoundationTable[i, j], 3)
                    else  # Round other values to 4 decimal places
                        heaveAbove[i, j] = toFixed(heaveAboveFoundationTable[i, j], 4)
                    end
                end
            end
            heaveBelowFoundationTableRows, heaveBelowFoundationTableCols = size(heaveBelowFoundationTable)
            heaveBelow = Array{Union{Int, Float64, String}}(undef, heaveBelowFoundationTableRows, heaveBelowFoundationTableCols)
            for i=1:heaveBelowFoundationTableRows
                for j=1:heaveBelowFoundationTableCols
                    if j == 1   # Make sure Material Index is Int
                        heaveBelow[i, j] = Int(heaveBelowFoundationTable[i, j])
                    elseif j == 2  # Round Depth values to 3 decimal places
                        heaveBelow[i, j] = toFixed(heaveBelowFoundationTable[i, j], 3)
                    else  # Round other values to 4 decimal places
                        heaveBelow[i, j] = toFixed(heaveBelowFoundationTable[i, j], 4)
                    end
                end
            end

            # Write outputs
            out *= "Heave Distribution Above Foundation: \n\n"
            out *= pretty_table(String, heaveAbove; header = ["Element", "Depth ($(depthUnit))", "Delta Heave ($(depthUnit))", "Excess Pore Pressure (tsf)"],tf = tf_markdown)
            out *= "\n"
            out *= "Heave Distribution Below Foundation: \n\n"
            out *= pretty_table(String, heaveBelow; header = ["Element", "Depth ($(depthUnit))", "Delta Heave ($(depthUnit))", "Excess Pore Pressure (tsf)"],tf = tf_markdown)
            out *= "\n"
        else
            out *= "Not enough increments to show tables\n\n"
        end
    end

    out *= "Soil Heave Next to Foundation Excluding Heave in Subsoil Beneath Foundation: " * toFixed(Δh1, 4) * " $(depthUnit)\n"
    out *= "Subsoil Movement: " * toFixed(Δh2, 4) * " $(depthUnit)\n"
    out *= "Total Heave: " * toFixed(Δh, 4) * " $(depthUnit)\n"

    return out
end
@doc raw"""
    getValue(behaviour::ConsolidationSwellCalculationBehaviour)

This functions first calls `getEffectiveStress()` and `getSurchargePressure()` with `behaviour` as the argument to
establish the two arrays `P` and `PP`. It then calculates total heave (`Δh`), subsoil movement (`Δh2`), and heave 
above foundation (`Δh1`). It also calculates values at each depth increment and places them in two tables, 
`heaveAboveFoundationTable` and `heaveBelowFoundationTable`. Returns tuple (`P`, `PP`, `heaveAboveFoundationTable`, 
`heaveBelowFoundationTable`, `Δh1`, `Δh2`, `Δh`)

# Calculations

``\Delta e_j = C_c \log_{10}{\frac{\sigma_{fj}'}{\sigma_{oj}'}} \text{, if } \sigma_{fj}' < \sigma_{pj}'``

``\Delta e_j = C_r \log_{10}{\frac{\sigma_{pj}'}{\sigma_{oj}'}} + C_c \log_{10}{\frac{\sigma_{fj}'}{\sigma_{pj}'}} \text{, if } \sigma_{fj}' \ge \sigma_{pj}'``

``\sigma_{oj}' = \frac{\sigma_{oj1}' + \sigma_{oj2}'}{2}``

``\rho_{cj} = \frac{\Delta e_j}{1 + e_{0j}}H_j``

``\rho_c = \sum_{j=1}^{n} \rho_{cj}``

# Variables

``\Delta e_j``: change in void ratio of soil layer *j*

``e_{0j}``: initial void ratio of soil layer *j*

``\sigma_{oj}'``: effective stress of layer *j*

``\sigma_{oj1}'``: effective stress at top of layer *j*

``\sigma_{oj2}'``: effective stress at bottom of layer *j*

``\sigma_{fj}'``: final applied effective stress of layer *j*

``C_c``: compression index

``C_r``: recompression index

``\rho_{cj}``: one-dimensional consolidation of layer *j*

``\rho_c``: oen-dimensional consolidation of soil profile

``H_j``: thickness of layer *j*

``n``: number of layers

> Note: Tables `heaveAboveFoundationTable` and `heaveBelowFoundationTable` contain the following values in each row: ``j``, ``\frac{dx}{2} + j \times dx``, ``\frac{\rho_{cj}}{H_j}``, ``\sigma_{fj}-\sigma_{oj}``

"""
function getValue(behaviour::ConsolidationSwellCalculationBehaviour)
    # Get effective stress
    P, PP = getEffectiveStress(behaviour)
    
    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Begin main calculations
    Δh1 = 0.0

    # Get Heave begin index
    heaveBeginIndex = 1
    depth = 0
    while depth < behaviour.groundToHeaveDepth
        depth += behaviour.dx[behaviour.soilLayerNumber[heaveBeginIndex]]
        heaveBeginIndex += 1
    end

    # Get Heave active index
    heaveActiveIndex = 1
    depth = 0
    while depth < behaviour.heaveActiveZoneDepth
        depth += behaviour.dx[behaviour.soilLayerNumber[heaveActiveIndex]]
        heaveActiveIndex += 1
    end

    # Get initial depth (Δx)
    Δx = behaviour.groundToHeaveDepth + (behaviour.dx[behaviour.soilLayerNumber[behaviour.bottomPointIndex]] / 2)
    foundationBottomIndex = behaviour.bottomPointIndex - 1
    if heaveActiveIndex > foundationBottomIndex
        heaveActiveIndex = foundationBottomIndex
    end

    # init table
    heaveAboveFoundationTable = []
    if heaveBeginIndex < heaveActiveIndex || behaviour.outputIncrements 
        for i=heaveBeginIndex:heaveActiveIndex
            material = behaviour.soilLayerNumber[i]
            pressure = (P[i]+ P[i+1])/2
            
            initialVoidRatio = behaviour.voidRatio[material]
            swellPressure = behaviour.swellPressure[material]
            swellIndex = behaviour.swellIndex[material]
            compressionIndex = behaviour.compressionIndex[material]
            maxPastPressure = behaviour.maxPastPressure[material]
            
            term1 = max(swellPressure / pressure, 0)
            term2 = max(swellPressure / maxPastPressure)
            term3 = max(maxPastPressure / pressure)

            finalVoidRatio = (pressure > maxPastPressure) ? initialVoidRatio + swellIndex * log10(term2) + compressionIndex * log10(term3) : initialVoidRatio + swellIndex * log10(term1)
            Δe = (finalVoidRatio - initialVoidRatio) / (1 + initialVoidRatio)
            
            Δp = swellPressure - pressure
            if size(heaveAboveFoundationTable, 1) == 0
                heaveAboveFoundationTable = [i Δx Δe Δp]
            else
                heaveAboveFoundationTable = vcat(heaveAboveFoundationTable, [i Δx Δe Δp]) 
            end
            
            Δh1 += behaviour.dx[material] * Δe
            Δx += behaviour.dx[material]
        end
    end
    
    Δh2 = 0.0
    Δx = float(behaviour.bottomPointIndex) * behaviour.dx[behaviour.soilLayerNumber[behaviour.bottomPointIndex]] - (behaviour.dx[behaviour.soilLayerNumber[behaviour.bottomPointIndex]]/2)
    heaveBelowFoundationTable = []
    for i=behaviour.bottomPointIndex:behaviour.elements
        material = behaviour.soilLayerNumber[i]
        pressure = (P[i]+ P[i+1])/2

        initialVoidRatio = behaviour.voidRatio[material]
        swellPressure = behaviour.swellPressure[material]
        swellIndex = behaviour.swellIndex[material]
        compressionIndex = behaviour.compressionIndex[material]
        maxPastPressure = behaviour.maxPastPressure[material]
        
        term1 = max(swellPressure / pressure, 0)
        term2 = max(swellPressure / maxPastPressure)
        term3 = max(maxPastPressure / pressure)

        finalVoidRatio = (pressure > maxPastPressure) ? initialVoidRatio + swellIndex * log10(term2) + compressionIndex * log10(term3) : initialVoidRatio + swellIndex * log10(term1)
        Δe = (finalVoidRatio - initialVoidRatio) / (1 + initialVoidRatio)
        
        
        Δp = swellPressure - pressure
        if size(heaveBelowFoundationTable, 1) == 0
            heaveBelowFoundationTable = [i Δx Δe Δp]
        else
            heaveBelowFoundationTable = vcat(heaveBelowFoundationTable, [i Δx Δe Δp]) 
        end
        
        Δh2 += behaviour.dx[material] * Δe
        Δx += behaviour.dx[material]
    end

    Δh = Δh1 + Δh2 

    return (P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, Δh1, Δh2, Δh)
end
######################################################

### LeonardFrostCalculationBehaviour "class" ####
struct LeonardFrostCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Array{Float64}
    soilLayerNumber::Array{Int}
    specificGravity::Array{Float64}
    waterContent::Array{Float64}
    voidRatio::Array{Float64}
    depthGroundWaterTable::Float64
    equilibriumMoistureProfile::Bool
    bottomPointIndex::Int
    appliedPressure::Float64
    foundation::String
    foundationLength::Float64
    foundationWidth::Float64
    center::Bool

    LeonardFrostCalculationBehaviour(effectiveStressValues, surchargePressureValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6])
end
function getOutput(behaviour::LeonardFrostCalculationBehaviour)
    # getValue does the calculations
    P, PP, x = getValue(behaviour)
    
    out = ""

    out *= "Random value: $(x)\n"

    return out
end
function getValue(behaviour::LeonardFrostCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (P, PP, 3*x)
end
######################################################

### SchmertmannCalculationBehaviour "class" ####
struct SchmertmannCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Array{Float64}
    soilLayerNumber::Array{Int}
    specificGravity::Array{Float64}
    waterContent::Array{Float64}
    voidRatio::Array{Float64}
    depthGroundWaterTable::Float64
    equilibriumMoistureProfile::Bool
    bottomPointIndex::Int
    appliedPressure::Float64
    foundation::String
    foundationLength::Float64
    foundationWidth::Float64
    center::Bool
    elements::Int
    timeAfterConstruction::Int
    conePenetrationResistance::Array{Float64}
    outputIncrements::Bool
    units::Int
    materialNames::Array{String}

    SchmertmannCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6], calcValues[1], calcValues[2], calcValues[3], calcValues[4], calcValues[5], calcValues[6])
end
function getOutput(behaviour::SchmertmannCalculationBehaviour)
    # getValue does the calculations
    P, PP, settlementTable, Δh = getValue(behaviour)
    
    out = ""

    # Output Material Properties Table 
    materialCount = size(behaviour.materialNames)[1]
    materialPropertiesTable = [1 behaviour.materialNames[1] behaviour.conePenetrationResistance[1]]
    for i=2:materialCount
        materialPropertiesTable = vcat(materialPropertiesTable, [i behaviour.materialNames[i] behaviour.conePenetrationResistance[i]])
    end

    pressureUnit = (behaviour.units == Int(InputParser.Imperial)) ? "tsf" : "KPa"
    
    out *= "Cone Penetration Resistance of Materials:\n\n"
    out *= pretty_table(String, materialPropertiesTable; header = ["Material", "Material Name", "Cone Penetration Resistance ($(pressureUnit))"],tf = tf_markdown)
    out *= "\n"

    depthUnit = (behaviour.units == Int(InputParser.Imperial)) ? "ft" : "m"

    out *= "Time After Construction in Years: " * string(behaviour.timeAfterConstruction) * "\n\n"

    if behaviour.outputIncrements
        # Copy calculations table to new table with values rounded to fixed number of digits
        settlementTableRows, settlementTableCols = size(settlementTable)
        _settlementTable = Array{Union{Int, String}}(undef, settlementTableRows, settlementTableCols)
        for i=1:settlementTableRows
            for j=1:settlementTableCols
                if j == 1  # Make sure Material Index is Int
                    _settlementTable[i, j] = Int(settlementTable[i, j])
                elseif j == 2  # Round Depth to 3 decimal places
                    _settlementTable[i, j] = toFixed(settlementTable[i, j], 3)
                else  # Round Settlement values to 4 decimal places
                    _settlementTable[i, j] = toFixed(settlementTable[i, j], 4)
                end
            end
        end

        out *= "Settlement Beneath Foundation at Each Depth Increment: \n\n"
        out *= pretty_table(String, _settlementTable; header = ["Element", "Depth ($(depthUnit))", "Settlement ($(depthUnit))"],tf = tf_markdown)
        out *= "\n"
    end

    out *= "Total Settlement Beneath Foundation: " * toFixed(Δh, 4) * "$(depthUnit)\n"

    return out
end
function getValue(behaviour::SchmertmannCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Perform calculations
    settlementTable, Δh = schmertmannApproximation(behaviour, false, PP)
    
    return (P, PP, settlementTable, Δh)
end
######################################################

### CollapsibleSoilCalculationBehaviour "class" ####
struct CollapsibleSoilCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Array{Float64}
    soilLayerNumber::Array{Int}
    specificGravity::Array{Float64}
    waterContent::Array{Float64}
    voidRatio::Array{Float64}
    depthGroundWaterTable::Float64
    equilibriumMoistureProfile::Bool
    bottomPointIndex::Int
    appliedPressure::Float64
    foundation::String
    foundationLength::Float64
    foundationWidth::Float64
    center::Bool

    CollapsibleSoilCalculationBehaviour(effectiveStressValues, surchargePressureValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6])
end
function getOutput(behaviour::CollapsibleSoilCalculationBehaviour)
    # getValue does the calculations
    P, PP, x = getValue(behaviour)
    
    out = ""
    out *= "Random value: $(x)\n"

    return out
end
function getValue(behaviour::CollapsibleSoilCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (P, PP, 3.1415)
end
######################################################

### SchmertmannElasticCalculationBehaviour "class" ####
struct SchmertmannElasticCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Array{Float64}
    soilLayerNumber::Array{Int}
    specificGravity::Array{Float64}
    waterContent::Array{Float64}
    voidRatio::Array{Float64}
    depthGroundWaterTable::Float64
    equilibriumMoistureProfile::Bool
    bottomPointIndex::Int
    appliedPressure::Float64
    foundation::String
    foundationLength::Float64
    foundationWidth::Float64
    center::Bool
    elements::Int
    timeAfterConstruction::Int
    conePenetrationResistance::Array{Float64}
    outputIncrements::Bool
    elasticModulus::Array{Float64}
    units::Int
    materialNames::Array{String}

    SchmertmannElasticCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6], calcValues[1], calcValues[2], calcValues[3], calcValues[4], calcValues[5], calcValues[6], calcValues[7])
end
function getOutput(behaviour::SchmertmannElasticCalculationBehaviour)
    # getValue does the calculations
    P, PP, settlementTable, Δh = getValue(behaviour)
    
    out = ""

    # Output Material Properties Table 
    materialCount = size(behaviour.materialNames)[1]
    materialPropertiesTable = [1 behaviour.materialNames[1] behaviour.elasticModulus[1]]
    for i=2:materialCount
        materialPropertiesTable = vcat(materialPropertiesTable, [i behaviour.materialNames[i] behaviour.elasticModulus[i]])
    end

    pressureUnit = (behaviour.units == Int(InputParser.Imperial)) ? "tsf" : "KPa"
    
    out *= "Elastic Modulus of Materials:\n\n"
    out *= pretty_table(String, materialPropertiesTable; header = ["Material", "Material Name", "Elastic Modulus ($(pressureUnit))"],tf = tf_markdown)
    out *= "\n"

    depthUnit = (behaviour.units == Int(InputParser.Imperial)) ? "ft" : "m"

    out *= "Time After Construction in Years: " * string(behaviour.timeAfterConstruction) * "\n\n"

    if behaviour.outputIncrements
        # Copy calculations table to new table with values rounded to fixed number of digits
        settlementTableRows, settlementTableCols = size(settlementTable)
        _settlementTable = Array{Union{Int, String}}(undef, settlementTableRows, settlementTableCols)
        for i=1:settlementTableRows
            for j=1:settlementTableCols
                if j == 1  # Make sure Material Index is Int
                    _settlementTable[i, j] = Int(settlementTable[i, j])
                elseif j == 2  # Round Depth to 3 decimal places
                    _settlementTable[i, j] = toFixed(settlementTable[i, j], 3)
                else  # Round Settlement values to 4 decimal places
                    _settlementTable[i, j] = toFixed(settlementTable[i, j], 4)
                end
            end
        end

        out *= "Settlement Beneath Foundation at Each Depth Increment: \n\n"
        out *= pretty_table(String, _settlementTable; header = ["Element", "Depth ($(depthUnit))", "Settlement ($(depthUnit))"],tf = tf_markdown)
        out *= "\n"
    end

    out *= "Total Settlement Beneath Foundation: " * toFixed(Δh, 4) * "$(depthUnit)\n"

    return out
end
function getValue(behaviour::SchmertmannElasticCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Perform calculations
    settlementTable, Δh = schmertmannApproximation(behaviour, true, PP)
    
    return (P, PP, settlementTable, Δh)
end
######################################################

@doc raw"""
    getEffectiveStress(behaviour)

Calculates the effective stress at each nodal point given values in the
`InputData` instance contained in `behaviour`. Returns two identical 
`Float64` arrays (unless model is ConsolidationSwell and equilibrium moisture 
profile is saturated above water table). `VDisp` never alters the second array
so the original effective stress values are always available for each nodal point, 
and alters the first array adding all other stress values to each corresponding
nodal point.

# Calculations

The effective stress at depth `z`, ``\sigma'_z``, is calculated using the following formulas:

``\sigma'_z = (\gamma_{sat}-\gamma_w)z``

Which can be derived from the following equations:

``\sigma_z = \sigma'_z + u_w``

``u_w = \gamma_w z``

``\sigma_z = \gamma_{sat} z``

This calculation is repeated at each depth increment.

The bulk unit weight, ``\gamma``, which is equal to ``\gamma_{sat}-\gamma_w`` 
is calculated by the following formula:

``\gamma = \frac{W}{V} = \frac{G_s (1+w) \gamma_w}{1+e}``

# Variables

``\sigma_z``: stress at depth `z`

``\sigma_z'``: effective stress at depth `z`

``\gamma_w``: unit weight of water

``\gamma_{sat}``: unit weight of saturated soil

``G_s``: specific gravity of soil

``w``: water content of soil

``e``: void ratio of soil
"""
function getEffectiveStress(behaviour::CalculationOutputBehaviour)
    # Initialize arrays
    P = Array{Float64}(undef,behaviour.nodalPoints)
    PP = Array{Float64}(undef,behaviour.nodalPoints)
    
    # Unit weight of water (0.03125 tcf = 62.4 pcf or 9810 N/m^3 = 0.981kN/m^3)
    GAMMA_W = (behaviour.units == Int(InputParser.Imperial)) ? 0.03125 : 0.9810

    # Initial values
    P[1] = 0.0
    PP[1] = 0.0 
    Δx = behaviour.dx[1]

    for i = 2:behaviour.nodalPoints
        # Get material of current soil layer
        material = behaviour.soilLayerNumber[i-1]
        # Get material properties
        waterContent = behaviour.waterContent[material]/100 # WC is given as percentage, we need the decimal value
        specificGravity = behaviour.specificGravity[material]
        voidRatio = behaviour.voidRatio[material]

        # Calculate gamma_sat (Saturated unit weight - i.e when voids are filled with water)
        gamma_sat = specificGravity * GAMMA_W * (1 + waterContent)/(1 + voidRatio)

        # If we are deeper than ground water table, subtract unit weight of water
        gamma_sat = (Δx > behaviour.depthGroundWaterTable) ? (gamma_sat - GAMMA_W) : gamma_sat
        
        # Effective stress of layer i is stress of previous layer plus gamma_sat*dx
        P[i] = P[i-1] + gamma_sat * behaviour.dx[material]
        PP[i] = P[i]

        Δx += behaviour.dx[material]
    end
    
    # The following code is from the original VDispl program. The theory behind it remains unclear to me.
    if behaviour.model == "ConsolidationSwell" && behaviour.equilibriumMoistureProfile
        # MO = DGWT/DX, but cannot be bigger than NNP
        groudWaterTableIndex = 1
        depth = 0
        while depth < behaviour.depthGroundWaterTable
            depth += behaviour.dx[behaviour.soilLayerNumber[groudWaterTableIndex]]
            groudWaterTableIndex += 1
            if groudWaterTableIndex == behaviour.elements
                break
            end
        end
        MO = min(groudWaterTableIndex, behaviour.nodalPoints)
        for i=1:MO 
            BN = groudWaterTableIndex - float(i-1)
            # weird dx behaviour
            index = (i < behaviour.nodalPoints) ? i : i - 1
            P[i] = P[i] + BN * GAMMA_W * behaviour.dx[behaviour.soilLayerNumber[index]]
        end
    end

    # Return arrays P and PP
    return (P, PP)
end

@doc raw"""
    getSurchargePressure(behaviour, P, PP)

Calculates the stress after adding foundation at each nodal point below the foundation.
The values are added to array `P`, while array `PP` remains unchanged. `VDisp` software 
calls this function using `P` and `PP` returned from the `getEffectiveStress()` function.

# Calculations

Using the Boussinesq equation for stress at a point under the corner of a rectangular 
area, the stress from adding the foundation is calculated at each depth increment. If
the calculation must be done from the center (i.e. `behaviour.center == true`), the 2:1
method is used: length, `a`, and width, `b`, are halved, while the whole equation is 
multiplied by a factor of 4 (the leading factor becomes ``\frac{2q}{\pi}`` rather than 
``\frac{q}{2\pi}``. This is because the calculation in the center can be seen as splitting
the rectangular area into 4 quadrants, where the original *center* is a *corner* for each 
rectangle. Now the Boussinesq equation for stress at a point under the *corner* of a
rectangular area can be used, however there are 4 of these rectangles contributing to the
load, hence the multiplication by a factor of 4). The stress increase at depth `z` is denoted 
as ``\sigma_z``, and is calculated using the following equation:

``\sigma_z = \frac{q}{2 \pi} (\text{tan}^{-1}(\frac{ab}{zC})+\frac{abz}{C}(\frac{1}{A^2}+\frac{1}{B^2})) \text{ where,}``

``A^2 = a^2 + z^2``

``B^2 = b^2 + z^2``

``C = \sqrt{a^2+b^2+z^2}``

# Variables

``q``: net applied footing pressure

``\sigma_z``: stress increase at depth `z`

``a``: length of the foundation

``b``: width of the foundation

``z``: depth

"""
function getSurchargePressure(behaviour, P::Array{Float64}, PP::Array{Float64})
    # Depth
    Δx = 0.0
    # Effective stress at bottom of foundation
    σ_bottom = PP[behaviour.bottomPointIndex]
    # Net applied footing pressure
    Qnet = behaviour.appliedPressure - σ_bottom

    # Loop through each nodal point below foundation
    for i=behaviour.bottomPointIndex:behaviour.nodalPoints
        if Δx < MIN_DX
            # This ensures pressure at bottom of foundation is equal to behaviour.appliedPressure
            P[i] += Qnet
            Δx += behaviour.dx[behaviour.soilLayerNumber[i]]
            continue
        end

        # Make calculations, add to effective stress at nodal point i
        if behaviour.foundation == "LongStripFooting"
            db = Δx / behaviour.foundationWidth
            ps = (db < 2.5 && behaviour.center) ? -0.28*db : -0.157 - 0.22*db
            ps *= 10
            P[i] += Qnet*ps
        else
            basePressure = (behaviour.center) ? Qnet : Qnet/4
            length = (behaviour.center) ? behaviour.foundationLength/2 : behaviour.foundationLength
            width = (behaviour.center) ? behaviour.foundationWidth/2 : behaviour.foundationWidth
            
            ve2 = (length^2 + width^2 + Δx^2)/(Δx^2)
            ve = sqrt(ve2)
            an = length*width/(Δx^2)

            enm = (2 * an * ve / (ve2 + an^2)) * (ve2+1)/ve2
            fnm = (2 * an * ve / (ve2 - an^2))

            ab = (fnm < 0) ? atan(fnm) + pi : atan(fnm)

            P[i] += basePressure * (enm+ab)/pi
        end

        # Increment depth
        index = (i < behaviour.nodalPoints) ? i : i -1
        Δx += behaviour.dx[behaviour.soilLayerNumber[index]]
    end
    return P
end

### SCHMERTMANN FUNCTION #############
@doc raw"""
    schmertmannApproximation(behaviour, elasticModulusGiven, PP)

Calculates settlement at each depth increment, ``\rho_i``, and sums it up to calculate total settlement, ``\rho``.
If `elasticModulus == true`, input file must have elastic moduli, ``E_{si}``, for each soil layer. Else, input file must 
have cone penetration resistance data, ``q_{ci}``, for each soil layer. Returns a 2D array of settlement values with each row 
containing the element number, the depth of the layer, and it's settlement.

# Calculations

This subroutine calculates total settlement using the **Schmertmann Approximation**:

``\rho = C_1 C_t \Delta p \Delta z \sum_{i=1}^{n} \frac{I_{iz}}{E_{si}} \text{ where, }``

``C_1 = 1 - \frac{0.5 \sigma_{od}'}{\Delta p}, C_1 \ge 0.5``

``C_t = 1 + 0.2 \log_{10} \frac{t}{0.1}``

``E_{si} = 2.5 q_{ci} \text{ if rectangular footing, } 3.5 q_{ci} \text{ if long strip footing}``

``I_{zp} = 0.5 + 0.1 \sqrt{\frac{\Delta p}{\sigma_{izp}'}}``

``I_{iz} = 0 \text{ if } z > 2w \text{,} \frac{4}{3}I_{zp} - \frac{I_{zp} z}{1.5w} \text{ if } z > 0.5w \text{ , else } 0.1 + \frac{(I_{zp}-0.1)z}{0.5w}``

``\sigma_{izp}' = \frac{\sigma_{topi}' + \sigma_{boti}'}{2}``

``\Delta p =  Q - \sigma_{od}'``

# Variables

``C_1``: correction to account for strain relief from embedment

``C_t``: correction for time dependant inrease in settlement 

``\sigma_{od}'``: effective stress at bottom of foundation

``\Delta p``: net applied footing pressure

``Q``: applied pressure 

``t``: time in years since construction

``\Delta z``: depth increment

``I_{iz}``: influence factor of soil layer `i`

``E_{si}``: elastic modulus of soil layer `i` 

``q_{ci}``: cone penetration resistance of soil layer `i` 

``\sigma_{topi}'``: effective stress at top of soil layer `i`

``\sigma_{boti}'``: effective stress at bottom of soil layer `i`

``\rho_i``: settlement of soil layer `i`

``\rho``: total settlement

# Code

The code first calculates the settlement of each soil layer, ``\rho_i``, then sums up settlements at each depth increment. The following two formulas are used to achieve this:

``\rho_i = C_1 C_t \Delta p \Delta z \frac{I_{iz}}{E_{si}}``

``\rho = \sum_{i=1}^{n} \rho_i``

"""
function schmertmannApproximation(behaviour, elasticModulusGiven::Bool, PP::Array{Float64})
    # Begin calculations
    Δh = 0.0
    Δh1 = 0.0

    # Net Applied Footing Pressure
    Qnet = behaviour.appliedPressure - PP[behaviour.bottomPointIndex]

    # TODO: Find a better way for dealing with negative Qnet
    Qnet = max(Qnet, 0) # Ensures Qnet is always non-negative

    # Foundation Depth and Index
    foundationMaterial = behaviour.soilLayerNumber[behaviour.bottomPointIndex]
    foundationDepth = 0
    for i = 1:behaviour.bottomPointIndex
        foundationDepth += behaviour.dx[behaviour.soilLayerNumber[i]]
    end
    Δx = foundationDepth - behaviour.dx[foundationMaterial]/2

    # Depth of nodal point above the base of foundation
    aboveFoundationDepth = 0
    for i = 1:behaviour.bottomPointIndex-1
        aboveFoundationDepth += behaviour.dx[behaviour.soilLayerNumber[i]]
    end

    # Correction to account for strain relief from embedment
    C1 = max(0.5, 1 - 0.5*PP[behaviour.bottomPointIndex]/Qnet)

    # Correction for time dependant increase in settlement
    time = behaviour.timeAfterConstruction/ 0.1
    Ct = 1 + 0.2*log10(time)

    settlementTable = []
    for i=behaviour.bottomPointIndex:behaviour.elements
        # Material properties of soil layer i
        material = behaviour.soilLayerNumber[i]
        conePenetrationRes = behaviour.conePenetrationResistance[material]
        
        # Average effective stress of soil layer i
        Δσ = (PP[i+1]+PP[i])/2

        # Elastic modulus of soil layer i
        Esi = (elasticModulusGiven) ? behaviour.elasticModulus[material] : (behaviour.foundation == "RectangularSlab") ? 2.5*conePenetrationRes : 3.5*conePenetrationRes

        Iz = 0.0
        if behaviour.foundation == "RectangularSlab"            
            halfWidth = 0.5 * behaviour.foundationWidth
            depth = Δx - aboveFoundationDepth
            Izp = 0.5 + 0.1 * sqrt(Qnet/Δσ) 
            # Influence factor of soil layer i
            Iz = (depth > halfWidth) ?  Izp + Izp/3 - Izp*depth/(3*halfWidth) : (depth > 4*halfWidth) ?  0.0 : 0.1 + (Izp-0.1) * depth/(halfWidth)
        else
            depth = Δx - aboveFoundationDepth
            Izp = 0.5 + 0.1 * sqrt(Qnet/Δσ)
            # Influence factor of soil layer i 
            Iz = (depth > behaviour.foundationWidth) ?  Izp + Izp/3 - Izp*depth/(3*behaviour.foundationWidth) : (depth > 4*behaviour.foundationWidth) ?  0.0 : 0.2 + (Izp-0.2) * depth/(behaviour.foundationWidth)
        end

        # Give names closer to original formula
        Δz = behaviour.dx[material]
        Δp = Qnet

        # Settlement of layer i 
        Δh_i = -C1 * Ct * Δp * Δz * Iz  / Esi

        # Add settlement of layer i to total settlement, Δh
        Δh += Δh_i

        # Append i Δx Δh_i to table
        if size(settlementTable,1) == 0
            settlementTable = [i Δx Δh_i]
        else
            settlementTable = vcat(settlementTable, [i Δx Δh_i])
        end

        # Increment current depth
        Δx += behaviour.dx[material]
    end

    return (settlementTable, Δh)
end

end # module