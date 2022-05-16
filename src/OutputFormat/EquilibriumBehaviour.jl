module EquilibriumBehaviour

export EquilibriumInfoBehaviour, EquilibriumHydrostaticBehaviour, EquilibriumSaturatedBehaviour, writeEquilibriumOutput, getEquilibriumOutput, getEquilibriumValue

### EquilibriumInfoBehaviour interface #########
abstract type EquilibriumInfoBehaviour end
# EquilibriumInfoBehaviour functions
function writeEquilibriumOutput(eqBehaviour::EquilibriumInfoBehaviour, path::String)
    open(path, "a") do file
        write(file, getEquilibriumOutput(eqBehaviour))
    end
end
function getEquilibriumOutput(eqBehaviour::EquilibriumInfoBehaviour)
    return getOutput(eqBehaviour)*"\n"
end
function getEquilibriumValue(eqBehaviour::EquilibriumInfoBehaviour)
    return getValue(eqBehaviour)
end
################################################

### EquilibriumSaturatedBehaviour "class" ######
struct EquilibriumSaturatedBehaviour <: EquilibriumInfoBehaviour
    equilibriumOption::Bool
    EquilibriumSaturatedBehaviour() = new(true)
end
getOutput(behaviour::EquilibriumSaturatedBehaviour) = "Equilibrium Saturated Above Water Table"
getValue(behaviour::EquilibriumSaturatedBehaviour) = behaviour.equilibriumOption
################################################

### EquilibriumSaturatedBehaviour "class" ######
struct EquilibriumHydrostaticBehaviour <: EquilibriumInfoBehaviour
    equilibriumOption::Bool
    EquilibriumHydrostaticBehaviour() = new(false)
end
getOutput(behaviour::EquilibriumHydrostaticBehaviour) = "Equilibrium Hydrostatic Profile Above Water Table"
getValue(behaviour::EquilibriumHydrostaticBehaviour) = behaviour.equilibriumOption
################################################

end # module