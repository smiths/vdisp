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
materialNamesQML = Observable([])
specificGravityQML = Observable([])
voidRatioQML = Observable([])
waterContentQML = Observable([])
# Enter Data Stage 3
boundsQML = Observable([])
subdivisionsQML = Observable([])
totalDepth = Observable(10.0)
soilLayerNumbersQML = Observable([])
depthToGroundWaterTable = Observable(5.0)
foundationDepth = Observable(2.5)
# Enter Data Stage 4 (Consolidation Swell)
heaveBegin = Observable(2.5)
heaveActive = Observable(7.5)
swellPressureQML = Observable([])
swellIndexQML = Observable([])
compressionIndexQML = Observable([])
recompressionIndexQML = Observable([])
# Enter Data Stage 4 (Schmertmann)
timeAfterConstruction = Observable(1)
conePenetrationQML = Observable([])
# Enter Data Stage 5 (Elastic Modulus)
elasticModulusQML = Observable([])

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
setMaterialNames = on(materialNamesQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSpecificGravity = on(specificGravityQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setVoidRatio = on(voidRatioQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setWaterContent = on(waterContentQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSubdivisions = on(subdivisionsQML) do val
    if PRINT_DEBUG
        println("\nGot an update for subdivisions: ", val)
    end
end
setTotalDepth = on(totalDepth) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
end
setSoilLayerNumbers = on(soilLayerNumbersQML) do val
    if PRINT_DEBUG
        println("\nGot an update for soilLayerNumbers: ", val)
    end
end
setBounds = on(boundsQML) do val
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
setSwellPressure = on(swellPressureQML) do val
    if PRINT_DEBUG
        println("\nGot an update for swellPressure: ", val)
    end
end
setSwellIndex = on(swellIndexQML) do val
    if PRINT_DEBUG
        println("\nGot an update for swellIndex: ", val)
    end
end
setCompressionIndex = on(compressionIndexQML) do val
    if PRINT_DEBUG
        println("\nGot an update for compressionIndex: ", val)
    end
end
setRecompressionIndex = on(recompressionIndexQML) do val
    if PRINT_DEBUG
        println("\nGot an update for recompressionIndex: ", val)
    end
end
setTimeAfterConstruction = on(timeAfterConstruction) do val
    if PRINT_DEBUG
        println("\nGot an update for timeAfterConstruction: ", val)
    end
end
setConePenetration = on(conePenetrationQML) do val
    if PRINT_DEBUG
        println("\nGot an update for conePenetration: ", val)
    end
end
setElasticMod = on(elasticModulusQML) do val
    if PRINT_DEBUG
        println("\nGot an update for elasticModulus: ", val)
    end
end

path = (size(ARGS)[1] == 2) ? "./src/UI/main.qml" : "../src/UI/main.qml"

# Load file main.qml
loadqml(path, props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNamesQML, "specificGravity" => specificGravityQML, "voidRatio" => voidRatioQML, "waterContent" => waterContentQML, "bounds" => boundsQML, "subdivisions" => subdivisionsQML, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbersQML, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth, "heaveActive" => heaveActive, "heaveBegin" => heaveBegin, "swellPressure" => swellPressureQML, "swellIndex" => swellIndexQML, "compressionIndex" => compressionIndexQML, "recompressionIndex" => recompressionIndexQML, "timeAfterConstruction" => timeAfterConstruction, "conePenetration" => conePenetrationQML, "elasticModulus" => elasticModulusQML))

if size(ARGS)[1] == 2
    # Run the app
    exec()

    # After app is done executing

    # Convert QML arrays to Julia Arrays
    materialNames = []
    specificGravity = []
    waterContent = []
    voidRatio = []
    bounds = []
    subdivisions = []
    soilLayerNumbers = []
    swellPressure = []
    swellIndex = []
    compressionIndex = []
    recompressionIndex = []
    conePenetration = []
    elasticModulus = []
    for i in 1:materials[]
        global materialNames, specificGravity, waterContent, voidRatio, subdivisions, soilLayerNumbers, swellPressure, swellIndex, compressionIndex, recompressionIndex, conePenetration, elasticModulus
        push!(materialNames, QML.value(materialNamesQML[][i]))
        push!(specificGravity, QML.value(specificGravityQML[][i]))
        push!(waterContent, QML.value(waterContentQML[][i]))
        push!(voidRatio, QML.value(voidRatioQML[][i]))
        push!(subdivisions, QML.value(subdivisionsQML[][i]))
        push!(soilLayerNumbers, QML.value(soilLayerNumbersQML[][i]))
        if model[] == 0
            push!(swellPressure, QML.value(swellPressureQML[][i]))
            push!(swellIndex, QML.value(swellIndexQML[][i]))
            push!(compressionIndex, QML.value(compressionIndexQML[][i]))
            push!(recompressionIndex, QML.value(recompressionIndexQML[][i]))
        elseif model[] == 1
            push!(conePenetration, QML.value(conePenetrationQML[][i]))
        else   
            push!(elasticModulus, QML.value(elasticModulusQML[][i]))
        end
    end
    for i = 1:1+materials[]
        global bounds
        push!(bounds, QML.value(boundsQML[][i]))
    end

    # Print Data
    println("\n\nFollowing Data Given:\n\n")

    if model[] == 0
        println("Problem Name: ", problemName[], " Model: ", model[], " Foundation: ", foundation[])
        println("Applied Pressure: ", appliedPressure[], " Center: ", center[])
        for i in 1:materials[]
            println("Material Name: ", materialNames[i], " Specific Gravity: ", specificGravity[i], " Void Ratio: ", voidRatio[i], " Water Content: ", waterContent[i])
        end
        println("Total Depth: ", totalDepth[])
        for i in 1:materials[]
            println("Soil Layer Number of Layer $i: ", soilLayerNumbers[i]) 
        end
        println("Heave Active: ", heaveActive[], " Heave Begin: ", heaveBegin[])
        for i in 1:materials[]
            println("Swell Pressure: ", swellPressure[i], " Swell Index: ", swellIndex[i], " Compression Index: ", compressionIndex[i], " Recompression Index: ", recompressionIndex[i])
        end
    elseif model[] == 1
        println("Problem Name: ", problemName[], " Model: ", model[], " Foundation: ", foundation[])
        println("Applied Pressure: ", appliedPressure[], " Center: ", center[])
        for i in 1:materials[]
            println("Material Name: ", materialNames[i], " Specific Gravity: ", specificGravity[i], " Void Ratio: ", voidRatio[i], " Water Content: ", waterContent[i])
        end
        println("Total Depth: ", totalDepth[])
        for i in 1:materials[]
            println("Soil Layer Number of Layer $i: ", soilLayerNumbers[i])
        end
        println("Time After Construction: ", timeAfterConstruction[])
        for i in 1:materials[]
            println("Cone Penetration of $(materialNames[i]): ", conePenetration[i])
        end
    else
        println("Problem Name: ", problemName[], " Model: ", model[], " Foundation: ", foundation[])
        println("Applied Pressure: ", appliedPressure[], " Center: ", center[])
        for i in 1:materials[]
            println("Material Name: ", materialNames[i], " Specific Gravity: ", specificGravity[i], " Void Ratio: ", voidRatio[i], " Water Content: ", waterContent[i])
        end
        println("Total Depth: ", totalDepth[])
        for i in 1:materials[]
            println("Soil Layer Number of Layer $i: ", soilLayerNumbers[i]) 
        end
        println("Time After Construction: ", timeAfterConstruction[])
        for i in 1:materials[]
            println("Elastic Modulus of $(materialNames[i]): ", elasticModulus[i])
        end
    end

    println("\nConverting to input file\n")

    # Calculate elements and nodal points
    elements = 0
    for i in subdivisions
        global elements += i
    end
    nodalPoints = elements + 1
    println("Elements: ", elements, ", Nodal Points: ", nodalPoints, "\n")

    # Calculate dx
    dx = []
    for i in 1:materials[]
        global bounds, subdivisions
        index = materials[] - i + 1
        push!(dx, (bounds[index]-bounds[index+1])/subdivisions[i])
    end
    println("dx: ", dx, "\n")

    # Soil layer numbers
    soilLayerNums = []
    for i in 1:materials[]
        global subdivisions
        for j in 1:subdivisions[i]
            global soilLayerNums, soilLayerNumbers
            push!(soilLayerNums, soilLayerNumbers[i]+1)
        end
    end
    println("Soil Layer Nums: ", soilLayerNums, "\n")

    # Foundation index, layer
    depth = 0
    foundationIndex = 0
    foundationLayer = 1
    increment = 0
    while depth < foundationDepth[]
        global depth, foundationIndex, foundationLayer, increment, subdivisions
        depth += dx[foundationLayer]
        foundationIndex += 1
        increment += 1
        if increment >= subdivisions[foundationLayer]
            foundationLayer += 1
            increment = 0
        end
    end

    modelConversion = [0, 2, 4] # Consolidation Swell NOPT = 0, Schmertmann NOPT = 2, Schemrtmann Elastic NOPT = 4

    content = ""
    content *= "1 " * string(modelConversion[model[]+1]) * " " * string(foundationIndex) * " " * string(materials[]) * "\n"
    for x in dx
        global content *= string(x) * " "
    end
    content *= "\n"
    content *= string(soilLayerNums) * "\n"

    print(content)

    # open("test.dat", "w") do file
    #     write(file, content)
    # end
end

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
