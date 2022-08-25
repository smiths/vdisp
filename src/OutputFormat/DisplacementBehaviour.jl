module DisplacementBehaviour

export DisplacementInfoBehaviour, TotalDisplacementBehaviour, DisplacementEachDepthBehaviour, writeDisplacementOutput, getDisplacementOutput, getDisplacementValue

### DisplacementInfoBehaviour interface #########
abstract type DisplacementInfoBehaviour end
# DisplacementInfoBehaviour functions 
function writeDisplacementOutput(dispBehaviour::DisplacementInfoBehaviour, path::String)
    open(path, "a") do file
        write(file, getDisplacementOutput(dispBehaviour))
    end
end
function getDisplacementOutput(dispBehaviour::DisplacementInfoBehaviour)
    return getOutput(dispBehaviour)*"\n"
end
function getDisplacementValue(dispBehaviour::DisplacementInfoBehaviour)
    return getValue(dispBehaviour)
end
###############################################

### TotalDisplacementBehaviour "class" ########
struct TotalDisplacementBehaviour <: DisplacementInfoBehaviour
    outputIncrements::Bool
    TotalDisplacementBehaviour()=new(false)
end
getOutput(behaviour::TotalDisplacementBehaviour) = "Total Displacements Only"
getValue(behaviour::TotalDisplacementBehaviour) = behaviour.outputIncrements
###############################################

### DisplacementEachDepthBehaviour "class" ########
struct DisplacementEachDepthBehaviour <: DisplacementInfoBehaviour
    outputIncrements::Bool
    DisplacementEachDepthBehaviour()=new(true)
end
getOutput(behaviour::DisplacementEachDepthBehaviour) = "Displacements at Each Depth Output"
getValue(behaviour::DisplacementEachDepthBehaviour) = behaviour.outputIncrements
###############################################
end # module