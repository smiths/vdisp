"""
Main module of VDisp software.
"""
module vdisp

include("./OutputFormat/OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser
include("./Constants.jl")
using .Constants

using Test
using QML
using Qt5QuickControls_jll
using Qt5QuickControls2_jll
using Observables
using Plots

export readInputFile

"""
      pathFromVar(str::String)
Removes *"file://"* prefix of `QUrl` paths
"""
pathFromVar(str::String) = if (length(str) > 7) return str[8:end] else return str end

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
units = UndefInitializer # This gets defined right before loading qml (Reads value from vdisp/src/.data/.units)

# Update QML variables
debugPrint(msg::String) = if PRINT_DEBUG println(msg) end
setProblemName = on(problemName) do val
    debugPrint("Got an update for problemName: $val")
end
setModel = on(model) do val
    debugPrint("Got an update for model: $val")
end
setFoundation = on(foundation) do val
    debugPrint("Got an update for foundation: $val")
end
setAppliedPressure = on(appliedPressure) do val 
    debugPrint("Got an update for appliedPressure: $val")
end
setPressurePoint = on(center) do val 
    debugPrint("Got an update for center: $val")
end
setLength = on(foundationLength) do val 
    debugPrint("Got an update for foundationLength: $val")
end
setWidth = on(foundationWidth) do val 
    debugPrint("Got an update for foundationWidth: $val")
end
setOutputIncrements = on(outputIncrements) do val 
    debugPrint("Got an update for outputIncrements: $val")
end
setSaturatedAboveWaterTable = on(saturatedAboveWaterTable) do val 
    debugPrint("Got an update for saturatedAboveWaterTable: $val")
end
setMaterials = on(materials) do val
    debugPrint("Got an update for materials: $val")
end
setMaterialNames = on(materialNamesQML) do val
    debugPrint("Got an update for materialNames: $val")
    
    matNames = Array{String}(undef,0)
    for v in val
        push!(matNames, QML.value(v))
    end
    global materialNames = copy(matNames)
end
setSpecificGravity = on(specificGravityQML) do val
    debugPrint("Got an update for specificGravity: $val")
    
    sg = Array{Float64}(undef,0)
    for v in val
        push!(sg, QML.value(v))
    end
    global specificGravity = copy(sg)
end
setVoidRatio = on(voidRatioQML) do val
    debugPrint("Got an update for voidRatio: $val")
    
    vr = Array{Float64}(undef,0)
    for v in val
        push!(vr, QML.value(v))
    end
    global voidRatio = copy(vr)
end
setWaterContent = on(waterContentQML) do val
    debugPrint("Got an update for waterContent: $val")
    
    wc = Array{Float64}(undef,0)
    for v in val
        push!(wc, QML.value(v))
    end
    global waterContent = copy(wc)
end
setSubdivisions = on(subdivisionsQML) do val
    debugPrint("Got an update for subdivisions: $val")

    sub = Array{Int32}(undef,0)
    for v in val
        push!(sub, QML.value(v))
    end
    global subdivisions = copy(sub)
end
setTotalDepth = on(totalDepth) do val
    debugPrint("Got an update for totalDepth: $val")
end
setSoilLayerNumbers = on(soilLayerNumbersQML) do val
    debugPrint("Got an update for soilLayerNumbers: $val")
    
    sln = Array{Int32}(undef,0)
    for v in val
        push!(sln, QML.value(v))
    end
    global soilLayerNumbers = copy(sln)
end
setBounds = on(boundsQML) do val
    debugPrint("Got an update for bounds: $val")
    
    b = Array{Float64}(undef,0)
    for v in val
        push!(b, QML.value(v))
    end
    global bounds = copy(b)
end
setDepthToGroundWaterTable = on(depthToGroundWaterTable) do val
    debugPrint("Got an update for depthToGroundWaterTable: $val")
end
setFoundationDepth = on(foundationDepth) do val
    debugPrint("Got an update for foundationDepth: $val")
end
setHeaveBegin = on(heaveBegin) do val
    debugPrint("Got an update for heaveBegin: $val")
end
setHeaveActive = on(heaveActive) do val
    debugPrint("Got an update for heaveEnd: $val")
end
setSwellPressure = on(swellPressureQML) do val
    debugPrint("Got an update for swellPressure: $val")

    sp = Array{Float64}(undef,0)
    for v in val
        push!(sp, QML.value(v))
    end
    global swellPressure = copy(sp)
end
setSwellIndex = on(swellIndexQML) do val
    debugPrint("Got an update for swellIndex: $val")
    si = Array{Float64}(undef,0)
    for v in val
        push!(si, QML.value(v))
    end
    global swellIndex = copy(si)
end
setCompressionIndex = on(compressionIndexQML) do val
    debugPrint("Got an update for compressionIndex: $val")
    ci = Array{Float64}(undef,0)
    for v in val
        push!(ci, QML.value(v))
    end
    global compressionIndex = copy(ci)
end
setRecompressionIndex = on(recompressionIndexQML) do val
    debugPrint("Got an update for maxPastPressure: $val")
    mpp = Array{Float64}(undef,0)
    for v in val
        push!(mpp, QML.value(v))
    end
    global recompressionIndex = copy(mpp)
end
setTimeAfterConstruction = on(timeAfterConstruction) do val
    debugPrint("Got an update for timeAfterConstruction: $val")
end
setConePenetration = on(conePenetrationQML) do val
    debugPrint("Got an update for conePenetration: $val")

    cp = Array{Float64}(undef,0)
    for v in val
        push!(cp, QML.value(v))
    end
    global conePenetration = copy(cp)
end
setElasticMod = on(elasticModulusQML) do val
    debugPrint("Got an update for elasticModulus: $val")

    em = Array{Float64}(undef,0)
    for v in val
        push!(em, QML.value(v))
    end
    global elasticModulus = copy(em)
end

"""
    createOutputDataFromGUI()

Returns `OutputData` instance created from data entered by user in **VDisp** GUI.
Data entered by user is accessed through the global `Observable` variables they are stored in.
"""
function createOutputDataFromGUI()
    global materialNames, specificGravity, voidRatio, waterContent, subdivisions, bounds, soilLayerNumbers, swellPressure, swellIndex, compressionIndex, recompressionIndex, elasticModulus, conePenetration
    
    if PRINT_DEBUG
        println("Converting Data")
    end

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

    # Soil layer numbers
    soilLayerNums = Array{Int32}(undef,0)
    for i in 1:materials[]
        for j in 1:subdivisions[i]
            push!(soilLayerNums, soilLayerNumbers[i])
        end
    end

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

    # Converting from dropdown menu index to value
    modelConversion = [Int(InputParser.ConsolidationSwell), Int(InputParser.Schmertmann), Int(InputParser.SchmertmannElastic)]
    foundationType = (foundation[] == 0) ? "RectangularSlab" : "LongStripFooting"

    if PRINT_DEBUG
        println("Data calculated")
    end

    # Heave Active Zone Depth spans from Heave Begin Depth to end of Heave Active Zone
    heaveDepth = heaveActive[] - heaveBegin[]

    # Creating OutputData Object
    outData = 0
    if model[] == 0
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, swellPressure, swellIndex, compressionIndex, recompressionIndex, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveDepth, heaveBegin[], totalDepth[], foundationDepth[], Int32(units[]))
    elseif model[] == 1
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, conePenetration, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], Int32(timeAfterConstruction[]), Int32(units[]))
    else
        outData = OutputData(problemName[], foundationType, Int32(materials[]), dx, soilLayerNums, Int32(nodalPoints), Int32(elements), materialNames, specificGravity, voidRatio, waterContent, subdivisions, Int32(foundationIndex), depthToGroundWaterTable[], saturatedAboveWaterTable[], outputIncrements[], appliedPressure[], foundationLength[], foundationWidth[], center[], heaveActive[], heaveBegin[], totalDepth[], foundationDepth[], elasticModulus, Int32(timeAfterConstruction[]), Int32(units[]))
    end

    if PRINT_DEBUG 
        println("OutputData created")
    end

    return outData
end

"""
    writeGUIDataToFile(path, outData)

`writeGUIDataToFile()` takes in a String, `path`, which represents a relative
file path and writes the contents of `writeDefaultOutput(path, outData)` to file at `path`
"""
writeGUIDataToFile(path::String, outData = createOutputDataFromGUI()) = writeDefaultOutput(outData, path)

"""
    getStressesFromArrays(P, PP, inData)

Returns a `Tuple` of 3 `Array{Float64}`s: `effectiveStresses`, `foundationStresses`, `totalStresses`. These arrays store
the effective stress, added stress from placing foundation, and sum of the effective and foundation stress of each soil layer.

They are calculated from the arrays `P` and `PP`, outputs of the `getEffectiveStress()` and `getSurchargePressure` functions in
the `CalculationBehaviour.jl` module, and data from an `InputData` instance. 
"""
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

# Output 
outputFileQML = Observable("")
on(outputFileQML) do val
    # Every time user selects output file, save to file
    writeGUIDataToFile(pathFromVar(val))
end
outputData = Observable([])
createOutputData = Observable(false)
outputDataCreated = Observable(false)
on(createOutputData) do val
    # If createOutputData changes to true
    if val
        outData = createOutputDataFromGUI()
        inData = outData.inputData
        outputParams = []
        
        # Consolidation / Swell
        if Int(inData.model) == Int(InputParser.ConsolidationSwell)
            P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, Δh1, Δh2, Δh = OutputFormat.performGetCalculationValue(outData)
            
            # When passing a 2D array into QML, it becomes 1D array so we need to know the number of rows
            heaveAboveFoundationTableRows = size(heaveAboveFoundationTable)[1]
            heaveBelowFoundationTableRows = size(heaveBelowFoundationTable)[1]
            
            # Get effective, foundation, and effective+foundation stresses for each layer
            effectiveStresses, foundationStresses, totalStresses = getStressesFromArrays(P, PP, inData)
            
            append!(outputParams, [inData.problemName, P, PP, heaveAboveFoundationTable, heaveAboveFoundationTableRows, heaveBelowFoundationTable, heaveBelowFoundationTableRows, Δh1, Δh2, Δh, effectiveStresses, totalStresses, foundationStresses])
        elseif Int(inData.model) == Int(InputParser.Schmertmann)  # Schmertmann
            P, PP, settlementTable, Δh = OutputFormat.performGetCalculationValue(outData)
            
            # When passing a 2D array into QML, it becomes 1D array so we need to know the number of rows
            settlementTableRows = size(settlementTable)[1]
            
            # Get effective, foundation, and effective+foundation stresses for each layer
            effectiveStresses, foundationStresses, totalStresses = getStressesFromArrays(P, PP, inData)
            
            append!(outputParams, [inData.problemName, inData.timeAfterConstruction, P, PP, settlementTable, settlementTableRows, Δh, effectiveStresses, foundationStresses, totalStresses])
        else  # Schmertmann Elastic (Kept this separate incase in the future we want to pass in Elastic Mod vs Cone Pen values)
            P, PP, settlementTable, Δh = OutputFormat.performGetCalculationValue(outData)
            
            # When passing a 2D array into QML, it becomes 1D array so we need to know the number of rows
            settlementTableRows = size(settlementTable)[1]
            
            # Get effective, foundation, and effective+foundation stresses for each layer
            effectiveStresses, foundationStresses, totalStresses = getStressesFromArrays(P, PP, inData)
            
            append!(outputParams, [inData.problemName, inData.timeAfterConstruction, P, PP, settlementTable, settlementTableRows, Δh, effectiveStresses, foundationStresses, totalStresses])
        end
        global outputData[] = outputParams
    
        outputDataCreated[] = true
    end
end
graphData = Observable(false)
on(graphData) do val 
    if val  # Only graph when graphData is changed to true
        debugPrint("Graphing Data...")

        if model[] == Int(InputParser.ConsolidationSwell)
            table1 = outputData[][4]  # heaveAboveFoundationTable
            table2 = outputData[][6]  # heaveBelowFoundationTable

            # Sometimes, heaveAboveFoundationTable could be empty
            heaveAbove = true
            if heaveBegin[] > foundationDepth[]
                heaveAbove = false
            end
            
            # Prepare Plot Axes
            depths1 = (heaveAbove) ? table1[:,2] : []
            depths2 = table2[:,2]
            heaveIncremental1 = (heaveAbove) ? table1[:,3] : []
            heaveIncremental2 = table2[:,3]
            
            # Calculate cumilative heave values
            s1 = size(heaveIncremental1)[1]
            s2 = size(heaveIncremental2)[1]
            heave1 = Array{Float64}(undef, s1)
            heave2 = Array{Float64}(undef, s2)
            if heaveAbove
                heave1[1] = heaveIncremental1[1]
                for i=2:s1
                    heave1[i] = heave1[i-1]+heaveIncremental1[i]
                end
            end
            heave2[1] = heaveIncremental2[1]
            for i=2:s2
                heave2[i] = heave2[i-1]+heaveIncremental2[i]
            end

            # Prepare effective stress vs depth data
            effectiveStress = outputData[][2]
            
            # Get material number of each sublayer, and dx of each layer
            soilSublayerMats = []
            dx = Array{Float64}(undef, materials[])
            for i=1:materials[]
                # Remember bounds array is backwards, thats why we index as materials - i
                Δx = (bounds[materials[]-(i-1)]-bounds[materials[]-(i-2)])/subdivisions[i]
                dx[soilLayerNumbers[i]] = round(Δx, digits=4)
                for j=1:subdivisions[i]
                    push!(soilSublayerMats, soilLayerNumbers[i])
                end
            end
            
            # Calculate the depth of each sublayer
            sublayers = size(soilSublayerMats)[1]
            allDepths = Array{Float64}(undef, sublayers+1) # Add extra entry for depth 0
            allDepths[1] = 0.0
            for i=2:sublayers
                allDepths[i] = allDepths[i-1] + dx[soilSublayerMats[i]]
            end
            allDepths[end] = totalDepth[] 

            # Normalize heave values based on sublayer size
            if heaveAbove
                heave1 = [Δh/dx[soilSublayerMats[i]] for (i, Δh) in enumerate(heave1)]
            end
            heave2 = [Δh/dx[soilSublayerMats[i]] for (i, Δh) in enumerate(heave2)]

            distUnits = units[] === Int(InputParser.Metric) ? "m" : "ft"
            pressureUnits = units[] === Int(InputParser.Metric) ? "Pa" : "tsf"

            heave1VsDepth = UndefInitializer
            if heaveAbove
                heave1VsDepth = Plots.plot(heave1, depths1,
                title = "Heave Contribution Above Foundation vs Depth", 
                ylabel = "Depth ($(distUnits))", xlabel = "Heave Per Unit Depth ($(distUnits))", 
                yflip = true, xflip = true,
                linecolor = RGBA(1,0.95,0.89,1), 
                markershape = :circle, 
                markercolor = RGBA(0.28,0.20,0.20,1), 
                markerstrokewidth = 0, 
                background_color = RGBA(0.42,0.31,0.31,1), 
                foreground_color = RGBA(1,0.95,0.89,1))
            end

            heave2VsDepth = Plots.plot(heave2, depths2,
            title = "Heave Contribution Below Foundation vs Depth", 
            ylabel = "Depth ($(distUnits))", xlabel = "Heave Per Unit Depth ($(distUnits))", 
            yflip = true, xflip = true,
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1))
            
            effectiveStressVsDepth = Plots.plot(effectiveStress, allDepths,
            title = "Effective Stress vs Depth", 
            ylabel = "Depth ($(distUnits))", xlabel = "Effective Stress ($(pressureUnits))", 
            yflip = true,
            label = "σ': effective stress",
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1)
            )

            p = (heaveAbove) ? Plots.plot(heave1VsDepth, heave2VsDepth, effectiveStressVsDepth, layout=(3,1), legend=false,background_color = RGBA(0.42,0.31,0.31,1), foreground_color = RGBA(1,0.95,0.89,1)) : Plots.plot(heave2VsDepth, effectiveStressVsDepth, layout=(2,1), legend=false,background_color = RGBA(0.42,0.31,0.31,1), foreground_color = RGBA(1,0.95,0.89,1))
            

            Base.invokelatest(display, p)
        else
            # Get output table
            table = outputData[][5]

            # Prepare Settlement vs Depth
            depths = table[:,2]
            incrementalSettlements = table[:, 3]
            
            # Convert incremental settlement values to cumalitive
            incrementalSettlementsSize = size(incrementalSettlements)[1]
            settlements = Array{Float64}(undef, incrementalSettlementsSize)
            settlements[1] = incrementalSettlements[1]
            for i=2:incrementalSettlementsSize
                settlements[i] = settlements[i-1]+incrementalSettlements[i]
            end
            
            # Prepare effective stress vs depth data
            effectiveStress = outputData[][3]
            
            # Get material number of each sublayer, and dx of each layer
            soilSublayerMats = []
            dx = Array{Float64}(undef, materials[])
            for i=1:materials[]
                # Remember bounds array is backwards, thats why we index as materials - i
                Δx = (bounds[materials[]-(i-1)]-bounds[materials[]-(i-2)])/subdivisions[i]
                dx[soilLayerNumbers[i]] = round(Δx, digits=4)
                for j=1:subdivisions[i]
                    push!(soilSublayerMats, soilLayerNumbers[i])
                end
            end

            # Normalize settlement values based on sublayer size
            settlements = [Δh/dx[soilSublayerMats[i]] for (i, Δh) in enumerate(settlements)]

            # Calculate the depth of each sublayer
            sublayers = size(soilSublayerMats)[1]
            allDepths = Array{Float64}(undef, sublayers+1) # Add extra entry for depth 0
            allDepths[1] = 0.0
            for i=2:sublayers
                allDepths[i] = allDepths[i-1] + dx[soilSublayerMats[i]]
            end
            allDepths[end] = totalDepth[]            

            # Create Plots
            distUnits = units[] === Int(InputParser.Metric) ? "m" : "ft"
            pressureUnits = units[] === Int(InputParser.Metric) ? "Pa" : "tsf"
            
            settlementVsDepth = Plots.plot(settlements, depths, 
            title = "Settlement vs Depth", 
            ylabel = "Depth ($(distUnits))", xlabel = "Settlement Per Unit Depth ($(distUnits))", 
            yflip = true, xflip = true,
            label = "Depth of Soil Profile",
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1)
            )

            effectiveStressVsDepth = Plots.plot(effectiveStress, allDepths,
            title = "Effective Stress vs Depth", 
            ylabel = "Depth ($(distUnits))", xlabel = "Effective Stress ($(pressureUnits))", 
            yflip = true,
            label = "σ': effective stress",
            linecolor = RGBA(1,0.95,0.89,1), 
            markershape = :circle, 
            markercolor = RGBA(0.28,0.20,0.20,1), 
            markerstrokewidth = 0, 
            background_color = RGBA(0.42,0.31,0.31,1), 
            foreground_color = RGBA(1,0.95,0.89,1)
            )

            plt = Plots.plot(settlementVsDepth, effectiveStressVsDepth, layout = (2,1), legend=false,background_color = RGBA(0.42,0.31,0.31,1), foreground_color = RGBA(1,0.95,0.89,1))

            Base.invokelatest(display, plt)
        end

        debugPrint("Done")
    end
end

# When runtests.jl compiles vdisp, there are no command line arguments. Skip loading the qml in that case
if size(ARGS)[1] == 1
    path = "./src/UI/main.qml"  # Path to main QML file when executing `make` command from `vdisp/` directory 
    
    if ARGS[1] == "debug"
        setDebug(true)
    end

    # Read last selected folder path
    LAST_DIR_FILE = "./src/.data/dir.dat"
    if !isfile(LAST_DIR_FILE)
        open(LAST_DIR_FILE, "w") do file  # Create file if it does not exist. Leave it blank.
            write(file, "")
        end
    end
    # Read contents of file
    lastInputFileDirContents = open(LAST_DIR_FILE) do file
        readlines(file)
    end
    # Initialize lastInputFileDir Observable
    lastInputFileDir = UndefInitializer
    # Check if file contents weren't empty
    if size(lastInputFileDirContents)[1] > 0
        # Check if directory listed in dir.dat actually exists
        if isdir(lastInputFileDirContents[1])
            lastInputFileDir = Observable(lastInputFileDirContents[1])
        else
            lastInputFileDir = Observable("") # Else leave empty (Code has been set up to default to home directory if lastInputFileDir is empty string in the QML FileDialog in EnterDataStage1.qml)
        end
    else
        lastInputFileDir = Observable("")  # Else leave empty (Code has been set up to default to home directory if lastInputFileDir is empty string in the QML FileDialog in EnterDataStage1.qml)
    end
    # Define what to do when lastInputFileDir is changed
    on(lastInputFileDir) do val
        open(LAST_DIR_FILE, "w") do file  # Update file to contain last selected input file directory
            write(file, pathFromVar(val))
        end
    end

    # Read preferred unit system
    UNITS_FILE = "./src/.data/.units"
    # If units file doesn't already exist, create it
    if !isfile(UNITS_FILE)
        open(UNITS_FILE, "w") do file
            write(file, string(InputParser.Imperial))  # Write Imperial by default
        end
    end
    # Read units file
    unitsContent = open(UNITS_FILE) do file
        readlines(file)
    end
    units = (unitsContent[1] == "Metric") ? Observable(Int(InputParser.Metric)) : Observable(Int(InputParser.Imperial))
    on(units) do val
        # Rewrite unit system value
        open(UNITS_FILE, "w") do file
            write(file, string(InputParser.Units(val)))
        end
    end

    # Load file main.qml
    loadqml(path, props=JuliaPropertyMap("problemName" => problemName, "model" => model, "foundation" => foundation, "appliedPressure" => appliedPressure, "center" => center, "foundationLength" => foundationLength, "foundationWidth" => foundationWidth, "outputIncrements" => outputIncrements, "saturatedAboveWaterTable" => saturatedAboveWaterTable, "materials" => materials, "materialNames" => materialNamesQML, "specificGravity" => specificGravityQML, "voidRatio" => voidRatioQML, "waterContent" => waterContentQML, "bounds" => boundsQML, "subdivisions" => subdivisionsQML, "totalDepth" => totalDepth, "soilLayerNumbers" => soilLayerNumbersQML, "depthToGroundWaterTable" => depthToGroundWaterTable, "foundationDepth" => foundationDepth, "heaveActive" => heaveActive, "heaveBegin" => heaveBegin, "swellPressure" => swellPressureQML, "swellIndex" => swellIndexQML, "compressionIndex" => compressionIndexQML, "recompressionIndex" => recompressionIndexQML, "timeAfterConstruction" => timeAfterConstruction, "conePenetration" => conePenetrationQML, "elasticModulus" => elasticModulusQML, "outputFile" => outputFileQML, "units"=>units, "inputFile" => inputFile, "inputFileSelected" => inputFileSelected, "materialCountChanged" => materialCountChanged, "modelChanged" => modelChanged, "outputDataCreated" => outputDataCreated, "createOutputData" => createOutputData, "outputData"=>outputData, "graphData" => graphData, "lastInputFileDir" => lastInputFileDir, "MAX_SUBDIVISIONS" => MAX_SUBDIVISIONS, "MAX_MATERIAL_COUNT" => MAX_MATERIAL_COUNT))
    
    # Run the app
    exec()
end

"""
    readInputFile(inputPath, outputPath)

Reads and parses input file at inputPath and outputs calculations to file at outputPath.

This function was used to emulate old `VDispl` software's CLI funcitonality. It is no longer 
used in this version of `VDisp`. It has been left in for any developers that would like to have
the command line funcitonality.
"""
function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)

    writeDefaultOutput(outputData, outputPath)
end

end # module
