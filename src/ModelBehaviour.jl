module ModelBehaviour
include("InputParser.jl")
using .InputParser

export ModelOutputBehaviour, LeonardFrostBehaviour, ConsolidationSwellBehaviour, SchmertmannBehaviour, CollapsibleSoilBehaviour, SchmertmannElasticBehaviour, writeOutput, getModelOutput, getModelValue

###  ModelOutputBehaviour Interface  ############
abstract type ModelOutputBehaviour end 
#  ModelOutputBehaviour functions
function writeOutput(modelOutBehaviour::ModelOutputBehaviour, path::String) 
    # Open file at path in append mode, write the output of 
    # the instance of ModelOutputBehaviour
    open(path, "a") do file
        write(file, getModelOutput(modelOutBehaviour))
    end
end
# Gets the string output of ModelOutputBehaviour instance
function getModelOutput(modelOutBehaviour::ModelOutputBehaviour)
    return getOutput(modelOutBehaviour)*"\n"
end
# Gets the value (in this case a Model) of ModelOutputBehaviour instance
function getModelValue(modelOutBehaviour::ModelOutputBehaviour)
    return getValue(modelOutBehaviour)
end
################################################

### ConsolidationSwellBehaviour "class" ########
struct ConsolidationSwellBehaviour <: ModelOutputBehaviour
    model::Model
    ConsolidationSwellBehaviour() = new(InputParser.ConsolidationSwell)
end
# ConsolidationSwellBehaviour functions
getOutput(behaviour::ConsolidationSwellBehaviour) = "Model: " * string(behaviour.model)
getValue(behaviour::ConsolidationSwellBehaviour) = behaviour.model
################################################

### LeonardFrostBehaviour "class" ##############
struct LeonardFrostBehaviour <: ModelOutputBehaviour
    model::Model
    LeonardFrostBehaviour() = new(InputParser.LeonardFrost)
end
# LeonardFrostBehaviour functions
getOutput(behaviour::LeonardFrostBehaviour) = "Model: " * string(behaviour.model)
getValue(behaviour::LeonardFrostBehaviour) = behaviour.model
################################################

### SchmertmannBehaviour "class" ################
struct SchmertmannBehaviour <: ModelOutputBehaviour
    model::Model
    SchmertmannBehaviour() = new(InputParser.Schmertmann)
end
# SchmertmannBehaviour functions
getOutput(behaviour::SchmertmannBehaviour) = "Model: " * string(behaviour.model)
getValue(behaviour::SchmertmannBehaviour) = behaviour.model
################################################

### SchmertmannElasticBehaviour "class" ########
struct SchmertmannElasticBehaviour <: ModelOutputBehaviour
    model::Model
    SchmertmannElasticBehaviour() = new(InputParser.SchmertmannElastic)
end
# SchmertmannElasticBehaviour functions
getOutput(behaviour::SchmertmannElasticBehaviour) = "Model: " * string(behaviour.model)
getValue(behaviour::SchmertmannElasticBehaviour) = behaviour.model
################################################

### CollapsibleSoilBehaviour "class" ###########
struct CollapsibleSoilBehaviour <: ModelOutputBehaviour
    model::Model
    CollapsibleSoilBehaviour() = new(InputParser.CollapsibleSoil)
end
# CollapsibleSoilBehaviour functions
getOutput(behaviour::CollapsibleSoilBehaviour) = "Model: " * string(behaviour.model)
getValue(behaviour::CollapsibleSoilBehaviour) = behaviour.model
################################################

end # module
