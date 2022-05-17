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
    #TODO: instead of passing in inputData, pass
    # in required data only
    inputData::InputData
    ConsolidationSwellCalculationBehaviour(inputData::InputData) = new(inputData)
end
function getOutput(behaviour::ConsolidationSwellCalculationBehaviour)
    # Temp print statement
    println("Calculating Consolidation Swell Model: ")
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3:$(t[3])"
end
function getValue(behaviour::ConsolidationSwellCalculationBehaviour)
    inData = behaviour.inputData
    x = inData.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (x^2 - 1, 2, 3)
end
######################################################

### LeonardFrostCalculationBehaviour "class" ####
struct LeonardFrostCalculationBehaviour <: CalculationOutputBehaviour
    #TODO: instead of passing in inputData, pass
    # in required data only
    inputData::InputData
    LeonardFrostCalculationBehaviour(inputData::InputData) = new(inputData)
end
function getOutput(behaviour::LeonardFrostCalculationBehaviour)
    # Temp print statement
    println("Calculating Leonard and Frost Model: ")
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3:$(t[3])"
end
function getValue(behaviour::LeonardFrostCalculationBehaviour)
    inData = behaviour.inputData
    x = inData.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (x^3 - x^2 + 1, 2.34, 3*x)
end
######################################################

### SchmertmannCalculationBehaviour "class" ####
struct SchmertmannCalculationBehaviour <: CalculationOutputBehaviour
    #TODO: instead of passing in inputData, pass
    # in required data only
    inputData::InputData
    SchmertmannCalculationBehaviour(inputData::InputData) = new(inputData)
end
function getOutput(behaviour::SchmertmannCalculationBehaviour)
    # Temp print statement
    println("Calculating Schmertmann Model: ")
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3:$(t[3])"
end
function getValue(behaviour::SchmertmannCalculationBehaviour)
    inData = behaviour.inputData
    x = inData.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (x^5 - 4*x^2 + 3, 2/x, 3*x-30)
end
######################################################

### CollapsibleSoilCalculationBehaviour "class" ####
struct CollapsibleSoilCalculationBehaviour <: CalculationOutputBehaviour
    #TODO: instead of passing in inputData, pass
    # in required data only
    inputData::InputData
    CollapsibleSoilCalculationBehaviour(inputData::InputData) = new(inputData)
end
function getOutput(behaviour::CollapsibleSoilCalculationBehaviour)
    # Temp print statement
    println("Calculating Collapsible Soil Model: ")
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3:$(t[3])"
end
function getValue(behaviour::CollapsibleSoilCalculationBehaviour)
    inData = behaviour.inputData
    x = inData.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (4*x^2 - 3*x, 2.2, 3.1415)
end
######################################################

### SchmertmannElasticCalculationBehaviour "class" ####
struct SchmertmannElasticCalculationBehaviour <: CalculationOutputBehaviour
    #TODO: instead of passing in inputData, pass
    # in required data only
    inputData::InputData
    SchmertmannElasticCalculationBehaviour(inputData::InputData) = new(inputData)
end
function getOutput(behaviour::SchmertmannElasticCalculationBehaviour)
    # Temp print statement
    println("Calculating Schmertmann Elastic Model: ")
    # getValue does the calculations
    t = getValue(behaviour)
    return "Random value 1: $(t[1])\nRandom value 2: $(t[2])\nRandom value 3:$(t[3])"
end
function getValue(behaviour::SchmertmannElasticCalculationBehaviour)
    inData = behaviour.inputData
    x = inData.nodalPoints
    # Just return some arbitrary calcultion for now
    # I will make each model return a different value 
    # to make sure things are working
    return (3.45*x^7 - 45*x^3 + 13.45*x, 2*x, 333*x-3)
end
######################################################

end # module