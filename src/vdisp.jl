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

export readInputFile

PRINT_DEBUG = true

# Julia variables
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

# QML variables
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
materialCountChanged = Observable(false)  # If we use input file, but alter number of materials, screen 3 breaks
boundsQML = Observable([])
subdivisionsQML = Observable([])
totalDepth = Observable(10.0)
soilLayerNumbersQML = Observable([])
depthToGroundWaterTable = Observable(5.0)
foundationDepth = Observable(2.5)
# Enter Data Stage 4 (Consolidation Swell)
modelChanged = Observable(false) # If we use input file, but change model, screen 4/5/6 breaks
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
# Misc
finishedInput = Observable(false)
outputFileQML = Observable("")
inputFile = Observable("")
inputFileSelected = Observable(false)
on(inputFileSelected) do val
    global inputFile

    # Only start process of auto fill if inputFileSelected was changed to true
    if val
        # Remove "file://" from inputFile 
        inputPath = inputFile[][7:end]

        # Parse input file
        guiData = 0
        inputFileWasAccepted = false
        message = ""
        try
            guiData = GUIData(inputPath)
            inputFileWasAccepted = true
        catch e
            println(e)
            args = []
            f = []
            if isa(e, MethodError)
                args = e.args
                f = e.f
                if string(f) == "Main.vdisp.InputParser.ModelError"
                    message = "Line $(args[1]): Model input should be 0, 1 or 2. Input was $(args[2])"
                elseif string(f) == "Main.vdisp.InputParser.UnitError"
                    message = "Line $(args[1]): Unit input should be 0, or 1. Input was $(args[2])"
                elseif string(f) == "Main.vdisp.InputParser.FoundationTypeError"
                    message = "Line $(args[1]): Foundation input should be 0 or 1. Input was $(args[2])"
                elseif string(f) == "Main.vdisp.InputParser.FloatConvertError"
                    message = "Line $(args[1]): $(args[2]) value should be a valid float value. Trouble parsing input \"$(args[3])\""
                elseif string(f) == "Main.vdisp.InputParser.IntConvertError"
                    message = "Line $(args[1]): $(args[2]) value should be a valid integer value. Trouble parsing input \"$(args[3])\""
                elseif string(f) == "Main.vdisp.InputParser.BoolConvertError"
                    message = "Line $(args[1]): $(args[2]) value should be a 0(false) or 1(true). Trouble parsing input \"$(args[3])\""
                elseif string(f) == "Main.vdisp.InputParser.DimensionNegativeError"
                    message = "Line $(args[1]): $(args[2]) value should be positive. Input was \"$(args[3])\""
                elseif string(f) == "Main.vdisp.InputParser.MaterialIndexOutOfBoundsError"
                    message = "Line $(args[1]): Invalid material index \"$(args[2])\""
                elseif string(f) == "Main.vdisp.InputParser.PropertyError"
                    message = args[1]
                else
                    message = "Unexpected error occured while parsing input file"
                end
            else
                message = "Unexpected error occured while parsing input file"
            end
            inputFileWasAccepted = false
        end
        
        # Emit correct signal
        if inputFileWasAccepted
            @emit inputFileAccepted([guiData.problemName, guiData.model, guiData.foundation, guiData.appliedPressure, guiData.appliedAt, guiData.foundationWidth, guiData.foundationLength, guiData.outputIncrements, guiData.saturatedAboveWaterTable, guiData.materialNames, guiData.specificGravity, guiData.voidRatio, guiData.waterContent, guiData.materials, guiData.totalDepth, guiData.depthGroundWaterTable, guiData.foundationDepth, reverse(guiData.bounds), guiData.subdivisions, guiData.soilLayerNumbers, guiData.heaveBeginDepth, guiData.heaveActiveDepth, guiData.swellPressure, guiData.swellIndex, guiData.compressionIndex, guiData.maxPastPressure, guiData.timeAfterConstruction, guiData.conePenetration, guiData.elasticModulus, guiData.units])
        else
            @emit inputFileRejected(message)
        end
    end
end
# Units
units = Observable(Int(InputParser.Imperial))


# Update QML variables
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
    matNames = Array{String}(undef,0)
    for v in val
        push!(matNames, QML.value(v))
    end
    global materialNames = copy(matNames)
end
setSpecificGravity = on(specificGravityQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
    sg = Array{Float64}(undef,0)
    for v in val
        push!(sg, QML.value(v))
    end
    global specificGravity = copy(sg)
end
setVoidRatio = on(voidRatioQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
    vr = Array{Float64}(undef,0)
    for v in val
        push!(vr, QML.value(v))
    end
    global voidRatio = copy(vr)
end
setWaterContent = on(waterContentQML) do val
    if PRINT_DEBUG
        println("Got an update: ", val)
    end
    wc = Array{Float64}(undef,0)
    for v in val
        push!(wc, QML.value(v))
    end
    global waterContent = copy(wc)
end
setSubdivisions = on(subdivisionsQML) do val
    if PRINT_DEBUG
        println("\nGot an update for subdivisions: ", val)
    end
    sub = Array{Int32}(undef,0)
    for v in val
        push!(sub, QML.value(v))
    end
    global subdivisions = copy(sub)
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
    sln = Array{Int32}(undef,0)
    for v in val
        push!(sln, QML.value(v))
    end
    global soilLayerNumbers = copy(sln)
end
setBounds = on(boundsQML) do val
    if PRINT_DEBUG
        println("\nGot an update for bounds: ", val)
    end
    b = Array{Float64}(undef,0)
    for v in val
        push!(b, QML.value(v))
    end
    global bounds = copy(b)
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
    sp = Array{Float64}(undef,0)
    for v in val
        push!(sp, QML.value(v))
    end
    global swellPressure = copy(sp)
end
setSwellIndex = on(swellIndexQML) do val
    if PRINT_DEBUG
        println("\nGot an update for swellIndex: ", val)
    end
    si = Array{Float64}(undef,0)
    for v in val
        push!(si, QML.value(v))
    end
    global swellIndex = copy(si)
end
setCompressionIndex = on(compressionIndexQML) do val
    if PRINT_DEBUG
        println("\nGot an update for compressionIndex: ", val)
    end
    ci = Array{Float64}(undef,0)
    for v in val
        push!(ci, QML.value(v))
    end
    global compressionIndex = copy(ci)
end
setRecompressionIndex = on(recompressionIndexQML) do val
    if PRINT_DEBUG
        println("\nGot an update for recompressionIndex: ", val)
    end
    mpp = Array{Float64}(undef,0)
    for v in val
        push!(mpp, QML.value(v))
    end
    global recompressionIndex = copy(mpp)
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
    cp = Array{Float64}(undef,0)
    for v in val
        push!(cp, QML.value(v))
    end
    global conePenetration = copy(cp)
end
setElasticMod = on(elasticModulusQML) do val
    if PRINT_DEBUG
        println("\nGot an update for elasticModulus: ", val)
    end
    em = Array{Float64}(undef,0)
    for v in val
        push!(em, QML.value(v))
    end
    global elasticModulus = copy(em)
end

# Don't load or run anything for tests
if size(ARGS)[1] == 2
    path = (size(ARGS)[1] == 2) ? "./src/UI/main.qml" : "../src/UI/main.qml"
    
    # Load file main.qml
    loadqml(path, props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNamesQML, "specificGravity" => specificGravityQML, "voidRatio" => voidRatioQML, "waterContent" => waterContentQML, "bounds" => boundsQML, "subdivisions" => subdivisionsQML, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbersQML, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth, "heaveActive" => heaveActive, "heaveBegin" => heaveBegin, "swellPressure" => swellPressureQML, "swellIndex" => swellIndexQML, "compressionIndex" => compressionIndexQML, "recompressionIndex" => recompressionIndexQML, "timeAfterConstruction" => timeAfterConstruction, "conePenetration" => conePenetrationQML, "elasticModulus" => elasticModulusQML, "finishedInput" => finishedInput, "outputFile" => outputFileQML, "units"=>units, "inputFile" => inputFile, "inputFileSelected" => inputFileSelected, "materialCountChanged" => materialCountChanged, "modelChanged" => modelChanged))
    
    # Run the app
    exec()

    # After app is done executing

    # Exit if form is not filled
    if !finishedInput[]
        println("Form not filled. Exiting app....")
        exit()
    end

    global materialNames, specificGravity, voidRatio, waterContent, subdivisions, bounds, soilLayerNumbers, swellPressure, swellIndex, compressionIndex, recompressionIndex, elasticModulus, conePenetration

    println("Converting Data")

    # Calculate elements and nodal points
    elements = 0
    for i in subdivisions
        global elements += i
    end
    nodalPoints = elements + 1

    # Calculate dx
    dx = Array{Float64}(undef,0)
    for i in 1:materials[]
        global bounds, dx, subdivisions, inputFileSelected
        index = materials[] - i + 1
        push!(dx, (bounds[index]-bounds[index+1])/subdivisions[i])
    end

    # Soil layer numbers
    soilLayerNums = Array{Int32}(undef,0)
    for i in 1:materials[]
        global subdivisions, soilLayerNumbers, soilLayerNums
        for j in 1:subdivisions[i]
            # In the input file, soil layer number index starts at 1, in GUI it starts at 0
            if inputFileSelected[]
                push!(soilLayerNums, soilLayerNumbers[i])
            else
                push!(soilLayerNums, soilLayerNumbers[i]+1)
            end
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
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, swellPressure, swellIndex, compressionIndex, recompressionIndex, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], Int32(units[]))
    elseif model[] == 1
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, conePenetration, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], Int32(timeAfterConstruction[]), Int32(units[]))
    else
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], elasticModulus, Int32(timeAfterConstruction[]), Int32(units[]))
    end

    println("OutputData created")

    # Remove "file://" from beginning of path
    outputPath = outputFileQML[][7:end]
    # defaultFile = "./src/.data/output_data.dat"
    
    writeDefaultOutput(outData, outputPath)
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
