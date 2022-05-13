module FoundationBehaviour

include("./InputParser.jl")
using .InputParser

export FoundationOutputBehaviour, writeFoundationOutput, getFoundationOutput, getFoundationValue, RectangularSlabBehaviour, LongStripFootingBehaviour

###  FoundationOutputBehaviour Interface  ############
abstract type FoundationOutputBehaviour end
# FoundationOutputBehaviour functions
function writeFoundationOutput(foundationOutBehaviour::FoundationOutputBehaviour, path::String)
    open(path, "a") do file
        write(file,getFoundationOutput(foundationOutBehaviour))
    end
end
function getFoundationOutput(foundationOutBehaviour::FoundationOutputBehaviour)
    return getOutput(foundationOutBehaviour)*"\n"
end
function getFoundationValue(foundationOutBehaviour::FoundationOutputBehaviour)
    return getValue(foundationOutBehaviour)
end
####################################################

### RectangularSlabBehaviour "class" ###############
struct RectangularSlabBehaviour <: FoundationOutputBehaviour
    foundation::Foundation
    RectangularSlabBehaviour()=new(InputParser.RectangularSlab)
end
getOutput(behaviour::RectangularSlabBehaviour) = "Foundation type: "*string(behaviour.foundation)
getValue(behaviour::RectangularSlabBehaviour) = behaviour.foundation
####################################################

### LongStripFootingBehaviour "class" ##############
struct LongStripFootingBehaviour <: FoundationOutputBehaviour
    foundation::Foundation
    LongStripFootingBehaviour()=new(InputParser.LongStripFooting)
end
getOutput(behaviour::LongStripFootingBehaviour) = "Foundation type: "*string(behaviour.foundation)
getValue(behaviour::LongStripFootingBehaviour) = behaviour.foundation
####################################################

end # module