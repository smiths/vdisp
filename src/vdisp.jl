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

PRINT_DEBUG = true

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
# Enter Data Stage 3
bounds = Observable([])
subdivisions = Observable([])
totalDepth = Observable(10.0)
soilLayerNumbers = Observable([])
depthToGroundWaterTable = Observable(5.0)
foundationDepth = Observable(2.5)

# Update system variables
setProblemName = on(problemName) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setModel = on(model) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setFoundation = on(foundation) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setAppliedPressure = on(appliedPressure) do val 
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setPressurePoint = on(center) do val 
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setLength = on(foundationLength) do val 
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setWidth = on(foundationWidth) do val 
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setOutputIncrements = on(outputIncrements) do val 
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSaturatedAboveWaterTable = on(saturatedAboveWaterTable) do val 
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setMaterials = on(materials) do val
    if PRINT_DEBUG
        println("\nGot an update for materials: ", val)
    end
end
setMaterialNames = on(materialNames) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSpecificGravity = on(specificGravity) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setVoidRatio = on(voidRatio) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setWaterContent = on(waterContent) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSubdivisions = on(subdivisions) do val
    if PRINT_DEBUG
        println("\nGot an update for subdivisions: ", val)
    end
end
setTotalDepth = on(totalDepth) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSoilLayerNumbers = on(soilLayerNumbers) do val
    if PRINT_DEBUG
        println("\nGot an update for soilLayerNumbers: ", val)
    end
end
setBounds = on(bounds) do val
    if PRINT_DEBUG
        println("\nGot an update for bounds: ", val)
    end
end
setDepthToGroundWaterTable = on(depthToGroundWaterTable) do val
    if PRINT_DEBUG
        println("\nGot an update for depthToGroundWaterTable: ", val)
    end
end
setFoundationDepth = on(foundationDepth) do val
    if PRINT_DEBUG
        println("\nGot an update for foundationDepth: ", val)
    end
end

# Load file main.qml
loadqml("./src/UI/main.qml", props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNames, "specificGravity" => specificGravity, "voidRatio" => voidRatio, "waterContent" => waterContent, "bounds" => bounds, "subdivisions" => subdivisions, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbers, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth))

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
