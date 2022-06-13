module CalculationBehaviour

using PrettyTables

include("../InputParser.jl")
using .InputParser

export CalculationOutputBehaviour, ConsolidationSwellCalculationBehaviour, LeonardFrostCalculationBehaviour, SchmertmannCalculationBehaviour, SchmertmannElasticCalculationBehaviour, CollapsibleSoilCalculationBehaviour, writeCalculationOutput, getCalculationOutput, getCalculationValue, getEffectiveStress, getSurchargePressure

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

@doc raw"""
    getEffectiveStress(behaviour)

Calculates the effective stress at each nodal point given values in the
`InputData` instance contained in `behaviour`. Returns two identical 
Float64 arrays (unless model is ConsolidationSwell and equilibrium moisture 
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
"""
function getEffectiveStress(behaviour::CalculationOutputBehaviour)
    # Initialize arrays (TODO: Think of better names)
    P = Array{Float64}(undef,behaviour.nodalPoints)
    PP = Array{Float64}(undef,behaviour.nodalPoints)
    
    # Initial values
    P[1] = 0.0
    PP[1] = 0.0 
    Δx = behaviour.dx

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
        P[i] = P[i-1] + gamma_sat * behaviour.dx
        PP[i] = P[i]

        Δx += behaviour.dx
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

``\sigma_z = \frac{q}{2 \pi} (\text{tan}^{-1}(\frac{ab}{zC})+\frac{abz}{C}(\frac{1}{A^2}+\frac{1}{B^2}))``

where,

``\sigma_z`` is the stress increase at depth `z`

``a`` is the length of the foundation

``b`` is the width of the foundation

``A^2 = a^2 + z^2``

``B^2 = b^2 + z^2``

``C = \sqrt{a^2+b^2+z^2}``

"""
function getSurchargePressure(behaviour, P::Array{Float64}, PP::Array{Float64})
    # Depth
    Δx = 0.0
    # Effective stress at bottom of foundation
    σ_bottom = PP[behaviour.bottomPointIndex]
    # Net applied footing pressure
    Qnet = behaviour.appliedPressure - σ_bottom
    for i=behaviour.bottomPointIndex:behaviour.nodalPoints
        if Δx < 0.01 # TODO: Why was this hardcoded to 0.01? Make this a constant. Maybe named MIN_DX?
            # This ensures pressure at bottom of foundation is 
            # equal to behaviour.appliedPressure
            P[i] += Qnet
            Δx += behaviour.dx
            continue
        end
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
        Δx += behaviour.dx
    end
    return P
end

end # module