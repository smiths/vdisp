module CalculationBehaviour

using PrettyTables

include("../InputParser.jl")
using .InputParser

export CalculationOutputBehaviour, ConsolidationSwellCalculationBehaviour, LeonardFrostCalculationBehaviour, SchmertmannCalculationBehaviour, SchmertmannElasticCalculationBehaviour, CollapsibleSoilCalculationBehaviour, writeCalculationOutput, getCalculationOutput, getCalculationValue

# For now this will be hardcoded into here, later it will
# rely on our choice of units
GAMMA_W = 0.03125

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
    dx::Float64
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

    ConsolidationSwellCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6],calcValues[1],calcValues[2],calcValues[3],calcValues[4],calcValues[5],calcValues[6],calcValues[7], calcValues[8])
end
function getOutput(behaviour::ConsolidationSwellCalculationBehaviour)
    # getValue does the calculations
    P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, Δh1, Δh2, Δh = getValue(behaviour)
    
    out = ""
    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(P[i])\n"
    end
    out *= "\n"

    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(PP[i])\n"
    end
    out *= "\n"

    if behaviour.outputIncrements
        out *= "Heave Distribution Above Foundation: \n"
        out *= pretty_table(String, heaveAboveFoundationTable; header = ["Element", "Depth (ft)", "Delta Heave (ft)", "Excess Pore Pressure (tsf)"],tf = tf_markdown)
        out *= "\n"
        out *= "Heave Distribution Below Foundation: \n"
        out *= pretty_table(String, heaveBelowFoundationTable; header = ["Element", "Depth (ft)", "Delta Heave (ft)", "Excess Pore Pressure (tsf)"],tf = tf_markdown)
        out *= "\n"
    end

    out *= "Soil Heave Next to Foundation Excluding Heave in Subsoil Beneath Foundation: " * string(Δh1) * "ft\n"
    out *= "Subsoil Movement: " * string(Δh2) * "ft\n"
    out *= "Total Heave: " * string(Δh) * "ft\n"

    return out
end
function getValue(behaviour::ConsolidationSwellCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Begin main calculations
    Δh1 = 0.0
    heaveBeginIndex = Int(floor(behaviour.groundToHeaveDepth / behaviour.dx))+1
    heaveActiveIndex = Int(floor(behaviour.heaveActiveZoneDepth / behaviour.dx))
    Δx = behaviour.groundToHeaveDepth + (behaviour.dx / 2)
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
            
            term1 = swellPressure / pressure
            term2 = swellPressure / maxPastPressure
            term3 = maxPastPressure / pressure

            finalVoidRatio = (pressure > maxPastPressure) ? initialVoidRatio + swellIndex * log10(term2) + compressionIndex * log10(term3) : initialVoidRatio + swellIndex * log10(term1)
            Δe = (finalVoidRatio - initialVoidRatio) / (1 + initialVoidRatio)

            if behaviour.outputIncrements
                Δp = swellPressure - pressure
                # TODO: Round values to a fixed number of decimal places
                if size(heaveAboveFoundationTable, 1) == 0
                    heaveAboveFoundationTable = [i Δx Δe Δp]
                else
                    heaveAboveFoundationTable = vcat(heaveAboveFoundationTable, [i Δx Δe Δp]) 
                end
            end
            Δh1 += behaviour.dx * Δe
            Δx += behaviour.dx
        end
    end
    
    Δh2 = 0.0
    Δx = float(behaviour.bottomPointIndex)*behaviour.dx - (behaviour.dx/2)
    heaveBelowFoundationTable = []
    for i=behaviour.bottomPointIndex:behaviour.elements
        material = behaviour.soilLayerNumber[i]
        pressure = (P[i]+ P[i+1])/2

        initialVoidRatio = behaviour.voidRatio[material]
        swellPressure = behaviour.swellPressure[material]
        swellIndex = behaviour.swellIndex[material]
        compressionIndex = behaviour.compressionIndex[material]
        maxPastPressure = behaviour.maxPastPressure[material]
        
        term1 = swellPressure / pressure
        term2 = swellPressure / maxPastPressure
        term3 = maxPastPressure / pressure

        finalVoidRatio = (pressure > maxPastPressure) ? initialVoidRatio + swellIndex * log10(term2) + compressionIndex * log10(term3) : initialVoidRatio + swellIndex * log10(term1)
        Δe = (finalVoidRatio - initialVoidRatio) / (1 + initialVoidRatio)
        
        if behaviour.outputIncrements
            Δp = swellPressure - pressure
            # TODO: Round values to a fixed number of decimal places
            if size(heaveBelowFoundationTable, 1) == 0
                heaveBelowFoundationTable = [i Δx Δe Δp]
            else
                heaveBelowFoundationTable = vcat(heaveBelowFoundationTable, [i Δx Δe Δp]) 
            end
        end
        Δh2 += behaviour.dx * Δe
        Δx += behaviour.dx
    end

    Δh = Δh1 + Δh2 

    return (P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, Δh1, Δh2, Δh)
end
######################################################

### LeonardFrostCalculationBehaviour "class" ####
struct LeonardFrostCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Float64
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
    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(P[i])\n"
    end
    out *= "\n"

    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(PP[i])\n"
    end
    out *= "\n"

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
    dx::Float64
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

    SchmertmannCalculationBehaviour(effectiveStressValues, surchargePressureValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6])
end
function getOutput(behaviour::SchmertmannCalculationBehaviour)
    # getValue does the calculations
    P, PP, x = getValue(behaviour)
    
    out = ""
    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(P[i])\n"
    end
    out *= "\n"

    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(PP[i])\n"
    end
    out *= "\n"

    out *= "Random value: $(x)\n"

    return out
end
function getValue(behaviour::SchmertmannCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (P, PP, 3*x-30)
end
######################################################

### CollapsibleSoilCalculationBehaviour "class" ####
struct CollapsibleSoilCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    model::String
    dx::Float64
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
    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(P[i])\n"
    end
    out *= "\n"

    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(PP[i])\n"
    end
    out *= "\n"

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
    dx::Float64
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

    SchmertmannElasticCalculationBehaviour(effectiveStressValues, surchargePressureValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6])
end
function getOutput(behaviour::SchmertmannElasticCalculationBehaviour)
    # getValue does the calculations
    P, PP, x = getValue(behaviour)
    
    out = ""
    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(P[i])\n"
    end
    out *= "\n"

    for i=1:behaviour.nodalPoints
        z = (i-1)*behaviour.dx 
        out *= "$(z), $(PP[i])\n"
    end
    out *= "\n"

    out *= "Random value: $(x)\n"

    return out
end
function getValue(behaviour::SchmertmannElasticCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Get surcharge pressure 
    P = getSurchargePressure(behaviour, P, PP)

    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (P, PP, 333*x-3)
end
######################################################

# Each calculation begins with an effective stress calculation
function getEffectiveStress(behaviour::CalculationOutputBehaviour)
    # Initialize arrays (TODO: Think of better names)
    P = Array{Float64}(undef,behaviour.nodalPoints)
    PP = Array{Float64}(undef,behaviour.nodalPoints)
    
    # Initial values
    P[1] = 0.0
    PP[1] = 0.0 
    dxx = behaviour.dx

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
        gamma_sat = (dxx > behaviour.depthGroundWaterTable) ? (gamma_sat - GAMMA_W) : gamma_sat
        
        # Effective stress of layer i is stress of previous layer plus gamma_sat*dx
        P[i] = P[i-1] + gamma_sat * behaviour.dx
        PP[i] = P[i]

        dxx += behaviour.dx
    end

    # Not sure why we have to do this, or theory behind it
    if behaviour.model == "ConsolidationSwell" && behaviour.equilibriumMoistureProfile
        # MO = DGWT/DX, but cannot be bigger than NNP
        MO = min(Int(floor(behaviour.depthGroundWaterTable/behaviour.dx)), behaviour.nodalPoints)
        for i=1:MO 
            BN = behaviour.depthGroundWaterTable/behaviour.dx - float(i-1)
            P[i] = P[i] + BN * GAMMA_W * behaviour.dx
        end
    end

    # Return arrays P and PP
    return (P, PP)
end

function getSurchargePressure(behaviour, P::Array{Float64}, PP::Array{Float64})
    # foundationDepth = behaviour.bottomPointIndex * behaviour.dx
    dxx = 0.0
    wt = PP[behaviour.bottomPointIndex]
    pressure1 = behaviour.appliedPressure - wt
    pressure = pressure1
    for i=behaviour.bottomPointIndex:behaviour.nodalPoints
        if dxx < 0.01
            P[i] += pressure
            dxx += behaviour.dx
            continue
        end
        # material = behaviour.soilLayerNumber[i-1]
        if behaviour.foundation == "LongStripFooting"
            db = dxx / behaviour.foundationWidth
            ps = (db < 2.5 && behaviour.center) ? -0.28*db : -0.157 - 0.22*db
            ps *= 10
            P[i] += pressure*ps
        else
            basePressure = (behaviour.center) ? pressure : pressure/4
            length = (behaviour.center) ? behaviour.foundationLength/2 : behaviour.foundationLength
            width = (behaviour.center) ? behaviour.foundationWidth/2 : behaviour.foundationWidth
            
            ve2 = (length^2 + width^2 + dxx^2)/(dxx^2)
            ve = sqrt(ve2)
            an = length*width/(dxx^2)

            enm = (2 * an * ve / (ve2 + an^2)) * (ve2+1)/ve2
            fnm = (2 * an * ve / (ve2 - an^2))

            ab = (fnm < 0) ? atan(fnm) + pi : atan(fnm)

            P[i] += basePressure * (enm+ab)/pi
        end
        dxx += behaviour.dx
    end
    return P
end

end # module