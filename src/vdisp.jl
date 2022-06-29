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

PRINT_DEBUG = false

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
# Enter Data Stage 4 (Consolidation Swell)
heaveBegin = Observable(2.5)
heaveActive = Observable(7.5)
swellPressure = Observable([])
swellIndex = Observable([])
compressionIndex = Observable([])
recompressionIndex = Observable([])
# Enter Data Stage 4 (Schmertmann)
timeAfterConstruction = Observable(1)
conePenetration = Observable([])
# Enter Data Stage 5 (Elastic Modulus)
elasticModulus = Observable([])

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
setHeaveBegin = on(heaveBegin) do val
    if PRINT_DEBUG
        println("\nGot an update for heaveBegin: ", val)
    end
end
setHeaveActive = on(heaveActive) do val
    if PRINT_DEBUG
        println("\nGot an update for heaveActive: ", val)
    end
end
setSwellPressure = on(swellPressure) do val
    if PRINT_DEBUG
        println("\nGot an update for swellPressure: ", val)
    end
end
setSwellIndex = on(swellIndex) do val
    if PRINT_DEBUG
        println("\nGot an update for swellIndex: ", val)
    end
end
setCompressionIndex = on(compressionIndex) do val
    if PRINT_DEBUG
        println("\nGot an update for compressionIndex: ", val)
    end
end
setRecompressionIndex = on(recompressionIndex) do val
    if PRINT_DEBUG
        println("\nGot an update for recompressionIndex: ", val)
    end
end
setTimeAfterConstruction = on(timeAfterConstruction) do val
    if PRINT_DEBUG
        println("\nGot an update for timeAfterConstruction: ", val)
    end
end
setConePenetration = on(conePenetration) do val
    if PRINT_DEBUG
        println("\nGot an update for conePenetration: ", val)
    end
end
setElasticMod = on(elasticModulus) do val
    if PRINT_DEBUG
        println("\nGot an update for elasticModulus: ", val)
    end
end

# Load file main.qml
loadqml("./src/UI/main.qml", props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNames, "specificGravity" => specificGravity, "voidRatio" => voidRatio, "waterContent" => waterContent, "bounds" => bounds, "subdivisions" => subdivisions, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbers, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth, "heaveActive" => heaveActive, "heaveBegin" => heaveBegin, "swellPressure" => swellPressure, "swellIndex" => swellIndex, "compressionIndex" => compressionIndex, "recompressionIndex" => recompressionIndex, "timeAfterConstruction" => timeAfterConstruction, "conePenetration" => conePenetration, "elasticModulus" => elasticModulus))

# Run the app
exec()

# After app is done executing
println("\n\nFollowing Data Given:\n\n")
if model[] == 0
    println("Problem Name: ", problemName[], " Model: ", model[], " Foundation: ", foundation[])
    println("Applied Pressure: ", appliedPressure[], " Center: ", center[])
    for i in 1:materials[]
        println("Material Name: ", QML.value(materialNames[][i]), " Specific Gravity: ", QML.value(specificGravity[][i]), " Void Ratio: ", QML.value(voidRatio[][i]), " Water Content: ", QML.value(waterContent[][i]))
    end
    println("Total Depth: ", totalDepth[])
    for i in 1:materials[]
        println("Soil Layer Number of Layer $i: ", QML.value(soilLayerNumbers[][i])) 
    end
    println("Heave Active: ", heaveActive[], " Heave Begin: ", heaveBegin[])
    for i in 1:materials[]
        println("Swell Pressure: ", QML.value(swellPressure[][i]), " Swell Index: ", QML.value(swellIndex[][i]), " Compression Index: ", QML.value(compressionIndex[][i]), " Recompression Index: ", QML.value(recompressionIndex[][i]))
    end
elseif model[] == 1
    println("Problem Name: ", problemName[], " Model: ", model[], " Foundation: ", foundation[])
    println("Applied Pressure: ", appliedPressure[], " Center: ", center[])
    for i in 1:materials[]
        println("Material Name: ", QML.value(materialNames[][i]), " Specific Gravity: ", QML.value(specificGravity[][i]), " Void Ratio: ", QML.value(voidRatio[][i]), " Water Content: ", QML.value(waterContent[][i]))
    end
    println("Total Depth: ", totalDepth[])
    for i in 1:materials[]
        println("Soil Layer Number of Layer $i: ", QML.value(soilLayerNumbers[][i])) 
    end
    println("Time After Construction: ", timeAfterConstruction[])
    for i in 1:materials[]
        println("Cone Penetration of $(QML.value(materialNames[][i])): ", QML.value(conePenetration[][i]))
    end
else
    println("Problem Name: ", problemName[], " Model: ", model[], " Foundation: ", foundation[])
    println("Applied Pressure: ", appliedPressure[], " Center: ", center[])
    for i in 1:materials[]
        println("Material Name: ", QML.value(materialNames[][i]), " Specific Gravity: ", QML.value(specificGravity[][i]), " Void Ratio: ", QML.value(voidRatio[][i]), " Water Content: ", QML.value(waterContent[][i]))
    end
    println("Total Depth: ", totalDepth[])
    for i in 1:materials[]
        println("Soil Layer Number of Layer $i: ", QML.value(soilLayerNumbers[][i])) 
    end
    println("Time After Construction: ", timeAfterConstruction[])
    for i in 1:materials[]
        println("Elastic Modulus of $(QML.value(materialNames[][i])): ", QML.value(elasticModulus[][i]))
    end
end

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
