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

finishedInput = Observable(false)

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
    println(val)
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

# Don't load or run anything for tests
if size(ARGS)[1] == 2
    path = (size(ARGS)[1] == 2) ? "./src/UI/main.qml" : "../src/UI/main.qml"
    
    # Load file main.qml
    loadqml(path, props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNamesQML, "specificGravity" => specificGravityQML, "voidRatio" => voidRatioQML, "waterContent" => waterContentQML, "bounds" => boundsQML, "subdivisions" => subdivisionsQML, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbersQML, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth, "heaveActive" => heaveActive, "heaveBegin" => heaveBegin, "swellPressure" => swellPressureQML, "swellIndex" => swellIndexQML, "compressionIndex" => compressionIndexQML, "recompressionIndex" => recompressionIndexQML, "timeAfterConstruction" => timeAfterConstruction, "conePenetration" => conePenetrationQML, "elasticModulus" => elasticModulusQML, "finishedInput" => finishedInput))
    
    # Run the app
    exec()

    # After app is done executing

    if !finishedInput[]
        println("Form not filled. Exiting app....")
        exit()
    end

    # Convert QML arrays to Julia Arrays
    materialNames = Array{String}(undef,0)
    specificGravity = Array{Float64}(undef,0)
    waterContent = Array{Float64}(undef,0)
    voidRatio = Array{Float64}(undef,0)
    bounds = Array{Float64}(undef,0)
    subdivisions = Array{Int32}(undef,0)
    soilLayerNumbers = Array{Int32}(undef,0)
    swellPressure = Array{Float64}(undef,0)
    swellIndex = Array{Float64}(undef,0)
    compressionIndex = Array{Float64}(undef,0)
    recompressionIndex = Array{Float64}(undef,0)
    conePenetration = Array{Float64}(undef,0)
    elasticModulus = Array{Float64}(undef,0)
    for i in 1:materials[]
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
        push!(bounds, QML.value(boundsQML[][i]))
    end

    println("New Julia Arrays created")

    # Calculate elements and nodal points
    elements = 0
    for i in subdivisions
        global elements += i
    end
    nodalPoints = elements + 1

    # Calculate dx
    dx = Array{Float64}(undef,0)
    for i in 1:materials[]
        global bounds, dx, subdivisions
        index = materials[] - i + 1
        push!(dx, (bounds[index]-bounds[index+1])/subdivisions[i])
    end

    # Soil layer numbers
    soilLayerNums = Array{Int32}(undef,0)
    for i in 1:materials[]
        global subdivisions, soilLayerNumbers, soilLayerNums
        for j in 1:subdivisions[i]
            push!(soilLayerNums, soilLayerNumbers[i]+1)
        end
    end

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

    # Converting from dropdown menu index to value
    modelConversion = [0, 2, 4] # Consolidation Swell NOPT = 0, Schmertmann NOPT = 2, Schemrtmann Elastic NOPT = 4
    foundationType = (foundation[] == 0) ? "RectangularSlab" : "LongStripFooting"

    println("Data calculated")

    # Creating OutputData Object
    outData = 0
    if model[] == 0
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, swellPressure, swellIndex, compressionIndex, recompressionIndex, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[])
    elseif model[] == 1
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, conePenetration, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], Int32(timeAfterConstruction[]))
    else
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], elasticModulus, Int32(timeAfterConstruction[]))
    end

    println("OutputData created")

    writeDefaultOutput(outData, "./src/.data/output_data.dat")
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
