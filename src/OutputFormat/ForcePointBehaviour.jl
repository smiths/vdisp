module ForcePointBehaviour

# Need Foundation enum to specify foundation type in EdgeForceBehaviour
include("../InputParser.jl")
using .InputParser

export ForcePointOutputBehaviour, writeForcePointOutput, getForcePointOutput, getForcePointValue, CenterForceBehaviour, EdgeForceBehaviour

### ForcePointOutputBehaviour interface #####
abstract type ForcePointOutputBehaviour end
# ForcePointOutputBehaviour functions
function writeForcePointOutput(fpBehaviour::ForcePointOutputBehaviour, path::String)
    open(path, "a") do file
        write(file, getForcePointOutput(fpBehaviour))
    end
end
function getForcePointOutput(fpBehaviour::ForcePointOutputBehaviour)
    return getOutput(fpBehaviour)*"\n"
end
function getForcePointValue(fpBehaviour::ForcePointOutputBehaviour)
    return getValue(fpBehaviour)
end
#############################################

### CenterForceBehaviour "class" ############
struct CenterForceBehaviour <: ForcePointOutputBehaviour
    center::Bool
    CenterForceBehaviour()=new(true)
end
getOutput(behaviour::CenterForceBehaviour) = "\tCenter of Foundation"
getValue(behaviour::CenterForceBehaviour) = behaviour.center
#############################################

### CenterForceBehaviour "class" ############
struct EdgeForceBehaviour <: ForcePointOutputBehaviour
    center::Bool
    foundation::Foundation
    CenterForceBehaviour(foundation::Foundation)=new(false)
end
getOutput(behaviour::EdgeForceBehaviour) = (string(behaviour.foundation) == "RectangularSlab") ? "\tCorner of Slab" : "\tEdge of Long Strip Footing"
getValue(behaviour::EdgeForceBehaviour) = behaviour.center
#############################################

end # module