module vdisp

include("./OutputFormat/OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser

using Test
using QML
using Qt5QuickControls_jll
using Qt5QuickControls2_jll
using Observables

export readInputFile, State

# System variables
# Enter Data Stage 1
problemName = Observable("")
model = Observable(0)
foundation = Observable(0)
appliedPressure = Observable(0.0)
center = Observable(true)
foundationLength = Observable(0.0)
foundationWidth = Observable(0.0)
outputIncrements = Observable(false)
saturatedAboveWaterTable = Observable(false)
# Enter Data Stage 2
materials = Observable(0)
materialNames = Observable([])
specificGravity = Observable([])
voidRatio = Observable([])
waterContent = Observable([])

# Update system variables
# Remove annoying println statements later
setProblemName = on(problemName) do val
    println("Got an update: ", val)
end
setModel = on(model) do val
    println("Got an update: ", val)
end
setFoundation = on(foundation) do val
    println("Got an update: ", val)
end
setAppliedPressure = on(appliedPressure) do val 
    println("Got an update: ", val)
end
setPressurePoint = on(center) do val 
    println("Got an update: ", val)
end
setLength = on(foundationLength) do val 
    println("Got an update: ", val)
end
setWidth = on(foundationWidth) do val 
    println("Got an update: ", val)
end
setOutputIncrements = on(outputIncrements) do val 
    println("Got an update: ", val)
end
setSaturatedAboveWaterTable = on(saturatedAboveWaterTable) do val 
    println("Got an update: ", val)
end
setMaterials = on(materials) do val
    println("Got an update: ", val)
end
setMaterialNames = on(materialNames) do val
    println("Got an update: ", val)
end
setSpecificGravity = on(specificGravity) do val
    println("Got an update: ", val)
end
setVoidRatio = on(voidRatio) do val
    println("Got an update: ", val)
end
setWaterContent = on(waterContent) do val
    println("Got an update: ", val)
end

# Load file main.qml
loadqml("./src/UI/main.qml", props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNames, "specificGravity" => specificGravity, "voidRatio" => voidRatio, "waterContent" => waterContent))

# Run the app
exec()


#if size(ARGS)[1] == 2
#    readInputFile(ARGS[1], ARGS[2])
#end

"""
    readInputFile(inputPath, outputPath)

Reads and parses input file at inputPath and outputs calculations to file at outputPath
"""
function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)

    writeDefaultOutput(outputData, outputPath)
end

end # module
