module CalculationBehaviour

include("../InputParser.jl")
using .InputParser

export CalculationOutputBehaviour, ConsolidationSwellCalculationBehaviour, LeonardFrostCalculationBehaviour, SchmertmannCalculationBehaviour, SchmertmannElasticCalculationBehaviour, CollapsibleSoilCalculationBehaviour, writeCalculationOutput, getCalculationOutput, getCalculationValue, getEffectiveStress

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
end
function getOutput(behaviour::ConsolidationSwellCalculationBehaviour)
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
function getValue(behaviour::ConsolidationSwellCalculationBehaviour)
    x = behaviour.nodalPoints

    # Get effective stress
    P, PP = getEffectiveStress(behaviour)

    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (P, PP, 3)
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

end # module