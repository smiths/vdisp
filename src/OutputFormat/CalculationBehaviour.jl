module CalculationBehaviour

using PrettyTables

include("../InputParser.jl")
using .InputParser

export CalculationOutputBehaviour, ConsolidationSwellCalculationBehaviour, LeonardFrostCalculationBehaviour, SchmertmannCalculationBehaviour, SchmertmannElasticCalculationBehaviour, CollapsibleSoilCalculationBehaviour, writeCalculationOutput, getCalculationOutput, getCalculationValue, getEffectiveStress, getSurchargePressure, getValue, schmertmannApproximation

# For now these will be hardcoded into here, later they will
# be part of a module of constants
GAMMA_W = 0.03125
OUTPUT_EFFECTIVE_STRESS = false

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

    if OUTPUT_EFFECTIVE_STRESS
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
    end

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

``\sigma_{oj}'``: effectuve stress of layer *j*

``\sigma_{oj1}'``: effective stress at top of layer *j*

``\sigma_{oj2}'``: effective stress at bottom of layer *j*

``\sigma_{fj}'``: final applied effective stress of layer *j*

``C_c``: compression index

``C_r``: recompression index

``\rho_{cj}``: one-dimensional consolidation of layer *j*

``H_j``: thickness of layer *j*

``n``: number of layers

> Note: Tables `heaveAboveFoundationTable` and `heaveBelowFoundationTable` contain the following values in each row: ``j``, ``\frac{dx}{2} + j \times dx``, ``\frac{\rho_{cj}}{H_j}``, ``\sigma_{fj}-\sigma_{oj}``

"""
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

    if OUTPUT_EFFECTIVE_STRESS
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
    end

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
    elements::Int
    timeAfterConstruction::Int
    conePenetrationResistance::Array{Float64}
    outputIncrements::Bool

    SchmertmannCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6], calcValues[1], calcValues[2], calcValues[3], calcValues[4])
end
function getOutput(behaviour::SchmertmannCalculationBehaviour)
    # getValue does the calculations
    P, PP, settlementTable, Δh = getValue(behaviour)
    
    out = ""

    if OUTPUT_EFFECTIVE_STRESS
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
    end

    out *= "Time After Construction in Years: " * string(behaviour.timeAfterConstruction) * "\n\n"

    if behaviour.outputIncrements
        out *= "Settlment Beneath Foundation at Each Depth Increment: \n"
        out *= pretty_table(String, settlementTable; header = ["Element", "Depth (ft)", "Settlment (ft)"],tf = tf_markdown)
        out *= "\n"
    end

    out *= "Total Settlement Beneath Foundation: " * string(Δh) * "ft\n"

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

    if OUTPUT_EFFECTIVE_STRESS
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
    end

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
    elements::Int
    timeAfterConstruction::Int
    conePenetrationResistance::Array{Float64}
    outputIncrements::Bool
    elasticModulus::Array{Float64}

    SchmertmannElasticCalculationBehaviour(effectiveStressValues, surchargePressureValues, calcValues) = new(effectiveStressValues[1],effectiveStressValues[2],effectiveStressValues[3],effectiveStressValues[4],effectiveStressValues[5],effectiveStressValues[6],effectiveStressValues[7],effectiveStressValues[8],effectiveStressValues[9],surchargePressureValues[1], surchargePressureValues[2],surchargePressureValues[3],surchargePressureValues[4],surchargePressureValues[5],surchargePressureValues[6], calcValues[1], calcValues[2], calcValues[3], calcValues[4], calcValues[5])
end
function getOutput(behaviour::SchmertmannElasticCalculationBehaviour)
    # getValue does the calculations
    P, PP, settlementTable, Δh = getValue(behaviour)
    
    out = ""

    if OUTPUT_EFFECTIVE_STRESS
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
    end

    out *= "Time After Construction in Years: " * string(behaviour.timeAfterConstruction) * "\n\n"

    if behaviour.outputIncrements
        out *= "Settlment Beneath Foundation at Each Depth Increment: \n"
        out *= pretty_table(String, settlementTable; header = ["Element", "Depth (ft)", "Settlment (ft)"],tf = tf_markdown)
        out *= "\n"
    end

    out *= "Total Settlement Beneath Foundation: " * string(Δh) * "ft\n"

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

# Variables

``\sigma_z``: stress at depth `z``

``\sigma_z'``: effective stress at depth `z`

``\gamma_w``: unit weight of water

``\gamma_{sat}``: unit weight of saturated soil
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
        if Δx < 0.01 # TODO: Why was this hardcoded to 0.01? Make this a constant. Maybe named MIN_DX?
            # This ensures pressure at bottom of foundation is equal to behaviour.appliedPressure
            P[i] += Qnet
            Δx += behaviour.dx
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
        Δx += behaviour.dx
    end
    return P
end

### SCHMERTMANN FUNCTION #############
@doc raw"""
    schmertmannApproximation(behaviour, elasticModulusGiven, PP)

Calculates settlement at each depth increment, ``\rho_i``, and sums it up to calculate total settlment, ``\rho``.
If `elasticModulus == true`, input file must have elastic moduli, ``E_{si}``, for each soil layer. Else, input file must 
have cone penetration resistance data, ``q_{ci}``, for each soil layer. Returns a 2D array of settlment values with each row 
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

``C_t``: correction for time dependant inrease in settlment 

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
    Δx = behaviour.dx * float(behaviour.bottomPointIndex) - behaviour.dx/2

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
            depth = Δx - float(behaviour.bottomPointIndex-1)*behaviour.dx
            Izp = 0.5 + 0.1 * sqrt(Qnet/Δσ) 
            # Influence factor of soil layer i
            Iz = (depth > halfWidth) ?  Izp + Izp/3 - Izp*depth/(3*halfWidth) : (depth > 4*halfWidth) ?  0.0 : 0.1 + (Izp-0.1) * depth/(halfWidth)
        else
            depth = Δx - float(behaviour.bottomPointIndex-1)*behaviour.dx
            Izp = 0.5 + 0.1 * sqrt(Qnet/Δσ)
            # Influence factor of soil layer i 
            Iz = (depth > behaviour.foundationWidth) ?  Izp + Izp/3 - Izp*depth/(3*behaviour.foundationWidth) : (depth > 4*behaviour.foundationWidth) ?  0.0 : 0.2 + (Izp-0.2) * depth/(behaviour.foundationWidth)
        end

        # Give names closer to original formula
        Δz = behaviour.dx
        Δp = Qnet

        # Settlment of layer i 
        Δh_i = -C1 * Ct * Δp * Δz * Iz  / Esi
        # Add settlemnt of layer i to total settlment, Δh
        Δh += Δh_i

        if behaviour.outputIncrements
            # Append i Δx Δh_i to table
            if size(settlementTable,1) == 0
                settlementTable = [i Δx Δh_i]
            else
                settlementTable = vcat(settlementTable, [i Δx Δh_i])
            end
        end

        # Increment current depth
        Δx += behaviour.dx
    end

    return (settlementTable, Δh)
end


end # module