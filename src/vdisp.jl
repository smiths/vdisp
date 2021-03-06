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
using Plots
using PlotlyJS

export readInputFile

PRINT_DEBUG = false

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

# Output functions
function createOutputDataFromGUI()
    global materialNames, specificGravity, voidRatio, waterContent, subdivisions, bounds, soilLayerNumbers, swellPressure, swellIndex, compressionIndex, recompressionIndex, elasticModulus, conePenetration
    
    println("Converting Data")

    # Calculate elements and nodal points
    elements = 0
    for i in subdivisions
        elements += i
    end
    nodalPoints = elements + 1

    # Calculate dx
    dx = Array{Float64}(undef,0)
    for i in 1:materials[]
        index = materials[] - i + 1
        push!(dx, (bounds[index]-bounds[index+1])/subdivisions[i])
    end

    outputDataProgress[] = 10

    # Soil layer numbers
    soilLayerNums = Array{Int32}(undef,0)
    for i in 1:materials[]
        for j in 1:subdivisions[i]
            push!(soilLayerNums, soilLayerNumbers[i])
        end
    end

    outputDataProgress[] = 30

    # Foundation index, layer
    depth = 0
    foundationIndex = 0
    foundationLayer = 1
    increment = 0
    while depth < foundationDepth[]
        depth += dx[foundationLayer]
        foundationIndex += 1
        increment += 1
        if increment >= subdivisions[foundationLayer]
            foundationLayer += 1
            increment = 0
        end
    end

    outputDataProgress[] = 45

    # Converting from dropdown menu index to value
    modelConversion = [Int(InputParser.ConsolidationSwell), Int(InputParser.Schmertmann), Int(InputParser.SchmertmannElastic)]
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

    outputDataProgress[] = 100

    return outData
end

"""
    writeGUIDataToFile(path, outData)

`writeGUIDataToFile()` takes in a String, `path`, which represents a relative
file path and writes the contents of `writeDefaultOutput(path, outData)` to file at `path`
"""
writeGUIDataToFile(path::String, outData = createOutputDataFromGUI()) = writeDefaultOutput(outData, path)

function getStressesFromArrays(P, PP, inData)
    # Get effective, foundation, and effective+foundation stresses for each layer
    # Initialize arrays
    effectiveStresses = []   
    totalStresses = []
    foundationStresses = []

    lastLayer = inData.soilLayerNumber[1]  # Store the layer value of the first sublayer 
    # Loop through each sublayer
    for i in 1:inData.elements 
        if inData.soilLayerNumber[i] != lastLayer  # If we encounter a different layer value
            push!(effectiveStresses, P[i-1])  # The previous entry in P[] was the effective stress of the bottom sublayer of lastLayer
            push!(totalStresses, PP[i-1])
            push!(foundationStresses, PP[i-1]-P[i-1])
            lastLayer = inData.soilLayerNumber[i]  # Update lastLayer
        end
    end
    # Append final layer stresses
    push!(effectiveStresses, P[end])
    push!(totalStresses, PP[end])
    push!(foundationStresses, PP[end]-P[end])

    return (effectiveStresses, foundationStresses, totalStresses)
end

pathFromVar(str::String) = str[7:end]

# Output 
outputFileQML = Observable("")
on(outputFileQML) do val
    # Every time user selects output file, save to file
    writeGUIDataToFile(pathFromVar(val))
end
outputData = Observable([])
createOutputData = Observable(false)
on(createOutputData) do val
    # If createOutputData changes to true
    if val
        outData = createOutputDataFromGUI()
        inData = outData.inputData
        outputParams = []
        
        # Consolidation / Swell
        if Int(inData.model) == Int(InputParser.ConsolidationSwell)
            P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, ??h1, ??h2, ??h = OutputFormat.performGetCalculationValue(outData)
            
            # When passing a 2D array into QML, it becomes 1D array so we need to know the number of rows
            heaveAboveFoundationTableRows = size(heaveAboveFoundationTable)[1]
            heaveBelowFoundationTableRows = size(heaveBelowFoundationTable)[1]
            
            # Get effective, foundation, and effective+foundation stresses for each layer
            effectiveStresses, foundationStresses, totalStresses = getStressesFromArrays(P, PP, inData)
            
            append!(outputParams, [inData.problemName, P, PP, heaveAboveFoundationTable, heaveAboveFoundationTableRows, heaveBelowFoundationTable, heaveBelowFoundationTableRows, ??h1, ??h2, ??h, effectiveStresses, totalStresses, foundationStresses])
        elseif Int(inData.model) == Int(InputParser.Schmertmann)  # Schmertmann
            P, PP, settlementTable, ??h = OutputFormat.performGetCalculationValue(outData)
            
            # When passing a 2D array into QML, it becomes 1D array so we need to know the number of rows
            settlementTableRows = size(settlementTable)[1]
            
            # Get effective, foundation, and effective+foundation stresses for each layer
            effectiveStresses, foundationStresses, totalStresses = getStressesFromArrays(P, PP, inData)
            
            append!(outputParams, [inData.problemName, inData.timeAfterConstruction, P, PP, settlementTable, settlementTableRows, ??h, effectiveStresses, foundationStresses, totalStresses])
        else  # Schmertmann Elastic (Kept this separate incase in the future we want to pass in Elastic Mod vs Cone Pen values)
            P, PP, settlementTable, ??h = OutputFormat.performGetCalculationValue(outData)
            
            # When passing a 2D array into QML, it becomes 1D array so we need to know the number of rows
            settlementTableRows = size(settlementTable)[1]
            
            # Get effective, foundation, and effective+foundation stresses for each layer
            effectiveStresses, foundationStresses, totalStresses = getStressesFromArrays(P, PP, inData)
            
            append!(outputParams, [inData.problemName, inData.timeAfterConstruction, P, PP, settlementTable, settlementTableRows, ??h, effectiveStresses, foundationStresses, totalStresses])
        end
        global outputData[] = outputParams
    end
end
outputDataCreated = Observable(false)
outputDataProgress = Observable(0.0)
on(outputDataProgress) do val 
    if val == 100
        outputDataCreated[] = true
    end
end
graphData = Observable(false)
on(graphData) do val 
    if val
        println("Graphing...")

        if model[] == Int(InputParser.ConsolidationSwell)
            table1 = outputData[][4]
            table2 = outputData[][6]

            # Prepare Plot Axes
            depths1 = table1[:,2]
            depths2 = table2[:,2]
            heave1 = table1[:,3]
            heave2 = table2[:,3]

            distUnits = units[] === Int(InputParser.Metric) ? "m" : "ft"

            p1 = Plots.plot(depths1, heave1,
            window_title = "VDisp: Heave vs Settlement",
            title = "Depth vs Heave Above Foundation", 
            xlabel = "Depth ($(distUnits))", ylabel = "Heave ($(distUnits))", 
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1))
        
            p2 = Plots.plot(depths2, heave2,
            title = "Depth vs Heave Below Foundation", 
            xlabel = "Depth ($(distUnits))", ylabel = "Heave ($(distUnits))", 
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1))
            
            p = Plots.plot(p1, p2, layout=(2,1), legend=false,background_color = RGBA(0.42,0.31,0.31,1), foreground_color = RGBA(1,0.95,0.89,1))

            Base.invokelatest(display, p)
        else
            table = outputData[][5]

            # Prepare Plot Axes
            depths = table[:,2]
            settlements = table[:, 3]
            
            # Select Backend
            # pyplot()
            # pygui(true)
            # plotlyjs()

            # Create Plot
            distUnits = units[] === Int(InputParser.Metric) ? "m" : "ft"
            p = Plots.plot(depths, settlements, 
            window_title = "VDisp: Depth vs Settlement",
            title = "Depth vs Settlement", 
            xlabel = "Depth ($(distUnits))", ylabel = "Settlement ($(distUnits))", 
            label = "Depth of Soil Profile",
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1)
            )

            Base.invokelatest(display, p)
        end

        println("Done")
    end
end

# Don't load or run anything for tests
if size(ARGS)[1] == 1
    path = "./src/UI/main.qml"  # Path to main QML file when executing `make` command from `vdisp/` directory 
    
    if ARGS[1] == "debug"
        global PRINT_DEBUG = true
    end

    # Load file main.qml
    loadqml(path, props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNamesQML, "specificGravity" => specificGravityQML, "voidRatio" => voidRatioQML, "waterContent" => waterContentQML, "bounds" => boundsQML, "subdivisions" => subdivisionsQML, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbersQML, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth, "heaveActive" => heaveActive, "heaveBegin" => heaveBegin, "swellPressure" => swellPressureQML, "swellIndex" => swellIndexQML, "compressionIndex" => compressionIndexQML, "recompressionIndex" => recompressionIndexQML, "timeAfterConstruction" => timeAfterConstruction, "conePenetration" => conePenetrationQML, "elasticModulus" => elasticModulusQML, "finishedInput" => finishedInput, "outputFile" => outputFileQML, "units"=>units, "inputFile" => inputFile, "inputFileSelected" => inputFileSelected, "materialCountChanged" => materialCountChanged, "modelChanged" => modelChanged, "outputDataCreated" => outputDataCreated, "outputDataProgress" => outputDataProgress, "createOutputData" => createOutputData, "outputData"=>outputData, "graphData" => graphData))
    
    # Run the app
    exec()

    # After app is done executing

    # Exit if form is not filled
    if !finishedInput[]
        println("Form not filled. Exiting app....")
        exit()
    end

    # defaultFile = "./src/.data/output_data.dat"
    writeGUIDataToFile(pathFromVar(outputFileQML[]))
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
