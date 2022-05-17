module CalculationBehaviour

include("../InputParser.jl")
using .InputParser

export CalculationOutputBehaviour, ConsolidationSwellCalculationBehaviour, LeonardFrostCalculationBehaviour, SchmertmannCalculationBehaviour, SchmertmannElasticCalculationBehaviour, CollapsibleSoilCalculationBehaviour, writeCalculationOutput, getCalculationOutput, getCalculationValue

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
    ConsolidationSwellCalculationBehaviour(nodalPoints::Int) = new(nodalPoints)
end
function getOutput(behaviour::ConsolidationSwellCalculationBehaviour)
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3: $(t[3])"
end
function getValue(behaviour::ConsolidationSwellCalculationBehaviour)
    x = behaviour.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (x^2 - 1, 2, 3)
end
######################################################

### LeonardFrostCalculationBehaviour "class" ####
struct LeonardFrostCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    LeonardFrostCalculationBehaviour(nodalPoints::Int) = new(nodalPoints)
end
function getOutput(behaviour::LeonardFrostCalculationBehaviour)
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3: $(t[3])"
end
function getValue(behaviour::LeonardFrostCalculationBehaviour)
     x = behaviour.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (x^3 - x^2 + 1, 2.34, 3*x)
end
######################################################

### SchmertmannCalculationBehaviour "class" ####
struct SchmertmannCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    SchmertmannCalculationBehaviour(nodalPoints::Int) = new(nodalPoints)
end
function getOutput(behaviour::SchmertmannCalculationBehaviour)
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3: $(t[3])"
end
function getValue(behaviour::SchmertmannCalculationBehaviour)
     x = behaviour.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (x^5 - 4*x^2 + 3, 2/x, 3*x-30)
end
######################################################

### CollapsibleSoilCalculationBehaviour "class" ####
struct CollapsibleSoilCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    CollapsibleSoilCalculationBehaviour(nodalPoints::Int) = new(nodalPoints)
end
function getOutput(behaviour::CollapsibleSoilCalculationBehaviour)
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3: $(t[3])"
end
function getValue(behaviour::CollapsibleSoilCalculationBehaviour)
     x = behaviour.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (4*x^2 - 3*x, 2.2, 3.1415)
end
######################################################

### SchmertmannElasticCalculationBehaviour "class" ####
struct SchmertmannElasticCalculationBehaviour <: CalculationOutputBehaviour
    nodalPoints::Int
    SchmertmannElasticCalculationBehaviour(nodalPoints::Int) = new(nodalPoints)
end
function getOutput(behaviour::SchmertmannElasticCalculationBehaviour)
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3: $(t[3])"
end
function getValue(behaviour::SchmertmannElasticCalculationBehaviour)
     x = behaviour.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (3.45*x^7 - 45*x^3 + 13.45*x, 2*x, 333*x-3)
end
######################################################

end # module