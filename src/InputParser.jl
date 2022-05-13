module InputParser

# Julia implicitly numbers Enum items 0,1,2,3,4 (in order)
# I put them in same order as FORTRAN code (i.e. NOPT=0 meant
# ConsolidationSwell so Int(ConsolidationSwell) = 0) however
# this wont matter since we should never be referring to the integer 
# values explicitly anyways
@enum Model ConsolidationSwell LeonardFrost Schmertmann CollapsibleSoil SchmertmannElastic 
@enum Foundation ErrorFoundation RectangularSlab LongStripFooting 

# These are variables/objects visible to all modules
# that include InputParser module
export Model, Foundation, InputData

# This code repeats many times in InputData constructor
"""
    parseCurrentLine(input, items, index)

Parses the string and *index*-th index of *input* array. Makes sure there are *items*
values separated by spaces in the string. 
"""
function parseCurrentLine(input::Array{String}, items::Int, index::Int)
    currentLine = input[index]
    # Tabs ruin splitting by space
    currentLine = replace(currentLine, "\t" => " ")
    currentLineData = split(currentLine, " ")
    currentLineData = filter(x -> x != "", currentLineData)
    # Check if data is there
    if size(currentLineData)[1] < items
        println("Error: Invalid input file!")
        println("\t>Line $(index): $(items) values expected")
        return -1
    end
    return currentLineData
end

# TODO: Search for error handling (throws Exception/ try-catch block)
# to make InputData constructor more robust. Many Type errors are 
# possible when converting input file

# struct for InputData (OOP in Julia)
struct InputData
    problemName::String
    numProblems::Int
    model::Model
    foundation::Foundation
    nodalPoints::Int
    elements::Int
    bottomPointIndex::Int
    soilLayers::Int
    dx::Float64
    soilLayerNumber::Array{Int}
    specificGravity::Array{Float64}
    waterContent::Array{Float64}
    voidRatio::Array{Float64}
    depthGroundWaterTable::Float64
    equilibriumMoistureProfile::Bool
    outputIncrements::Bool
    appliedPressure::Float64
    foundationLength::Float64
    foundationWidth::Float64
    center::Bool
    swellPressure::Array{Float64}
    swellIndex::Array{Float64}
    compressionIndex::Array{Float64}
    maxPastPressure::Array{Float64}
    pressureDilatometerA::Array{Float64}
    pressureDilatometerB::Array{Float64}
    conePenetrationResistance::Array{Float64}
    appliedPressureAtPoints::Array{Float64, 2}
    elasticModulus::Array{Float64}
    heaveActiveZoneDepth::Float64
    groundToHeaveDepth::Float64
    timeAfterConstruction::Int
    strainAtPoints::Array{Float64, 2}

    # Parses input file at filePath and returns corresponding InputData object
    function InputData(filePath::String)
        input = open(filePath) do file
            readlines(file)
        end

        # Only allow lines that have non empty space chars
        input = filter(contains(r"[^\s]"), input)
        
        # Keep track of last line read
        lastLineIndex = 0

        # Get title of problem
        problemName = input[lastLineIndex+1]
        lastLineIndex += 1

        # Get following data:
        #  NPROB NOPT NBPRES NNP NBX NMAT DX 
        dataLine1 = parseCurrentLine(input, 7, lastLineIndex+1)
        if dataLine1 == -1
            return
        end
        # Parse each value
        numProblems = parse(Int64, dataLine1[1])
        modelOption = parse(Int64, dataLine1[2])
        model = Model(modelOption) # Int -> Enum conversion
        foundationOption = parse(Int64, dataLine1[3]) # Rectangular Slab or Long Strip Footing
        foundation = (foundationOption == 1) ? RectangularSlab : (foundationOption == 2) ? LongStripFooting : ErrorFoundation
        if foundation == ErrorFoundation
            println("Error: Invalid input for foundation on line $(lastLineIndex+1)")
            println("\tExpected either 1 or 2, not $(foundationOption)")
            return # or instead of returning we can default to foundation = RectangularSlab
        end
        nodalPoints = parse(Int64, dataLine1[4])
        elements = nodalPoints - 1
        bottomPointIndex = parse(Int64, dataLine1[5])
        soilLayers = parse(Int64, dataLine1[6]) # NMAT
        dx = parse(Float64, dataLine1[7])
        lastLineIndex += 1

        # Soil layer number of element N
        soilLayerNumber = []  # Array IE(N,M) from FORTRAN Code
        lastElement = -1 # Index of last element we saw
        lastLayerNum = -1 # Last layerNum we saw
        for i in 1:soilLayers+1  # For each layer + last line that has NEL NMAT
            # Get current line and its data
            currentLineData = parseCurrentLine(input, 2, lastLineIndex + 1)
            if currentLineData == -1
                return
            end
            # Update last line read
            lastLineIndex += 1
            # element is first value
            element = parse(Int32, currentLineData[1])
            # layer number is second value
            layerNum = parse(Int32, currentLineData[2])
            if lastElement == -1  # We haven't seen an element before
                # push first layerNum value
                push!(soilLayerNumber, layerNum)
            else   # We have seen element before
                # Fill spots from last element to this one with 
                # last layer num 
                for j in lastElement+1:element-1
                    push!(soilLayerNumber, lastLayerNum)
                end
                # Fill current spot with current layer num
                push!(soilLayerNumber, layerNum)
            end
            # Update variables
            lastElement = element
            lastLayerNum = layerNum
        end

        # Material properties
        # Array of Float64s initialized with soilLayers amout of undefined values
        specificGravity = Array{Float64}(undef,soilLayers) 
        waterContent = Array{Float64}(undef,soilLayers)
        voidRatio = Array{Float64}(undef,soilLayers)
        for i in 1:soilLayers
            # Get current line
            currentLineData = parseCurrentLine(input, 4, lastLineIndex + i)
            if currentLineData == -1
                return
            end
            # Get each individual piece of data 
            # Format of each line: M SG WC VR
            m = parse(Int8, currentLineData[1])
            sg = parse(Float64, currentLineData[2])
            wc = parse(Float64, currentLineData[3])
            vr = parse(Float64, currentLineData[4])
            # Add each value at index M
            # Supports adding them in random orders of M
            specificGravity[m] = sg
            waterContent[m] = wc
            voidRatio[m] = vr 
        end
        # Increment last line to last line of material properties
        lastLineIndex += soilLayers

        # Read DGWT IOPTION NOUT
        currentLineData = parseCurrentLine(input, 3, lastLineIndex+1)
        if currentLineData == -1
            return
        end
        # Parse data
        depthGroundWaterTable = parse(Float64, currentLineData[1])
        equilibriumMoistureProfileOption = parse(Int8, currentLineData[2])
        # TODO: for robustness make sure equilibriumMoistureProfileOption is 0 or 1
        equilibriumMoistureProfile = (equilibriumMoistureProfileOption == 1) ? true : false
        outputIncrementsOption = parse(Int8, currentLineData[3])
        # TODO: for robustness make sure outputIncrementsOption is 0 or 1
        outputIncrements = (outputIncrementsOption == 1) ? true : false
        # Increment last line index 
        lastLineIndex += 1

        # Read Q BLEN BWID MRECT
        currentLineData = parseCurrentLine(input, 4, lastLineIndex+1)
        if currentLineData == -1
            return
        end
        # Parse data
        appliedPressure = parse(Float64, currentLineData[1])
        foundationLength = parse(Float64, currentLineData[2])
        foundationWidth = parse(Float64, currentLineData[3])
        forcePointOption = parse(Int, currentLineData[4])
        # TODO: for robustness make sure forcePointOption is 0 or 1
        center = (forcePointOption == 1) ? false : true
        # Increment last line index
        lastLineIndex += 1

        # Read M SP(M) CS(M) CC(M) PM(M)
        swellPressure = zeros(Float64, soilLayers)
        swellIndex = zeros(Float64, soilLayers)
        compressionIndex = zeros(Float64, soilLayers)
        maxPastPressure = zeros(Float64, soilLayers)
        if model == ConsolidationSwell
            for i in 1:soilLayers
                currentLineData = parseCurrentLine(input, 5, lastLineIndex + i)
                if currentLineData == -1
                    return
                end
                # Parse data 
                m = parse(Int32, currentLineData[1])
                sp = parse(Float64, currentLineData[2])
                cs = parse(Float64, currentLineData[3])
                cc = parse(Float64, currentLineData[4])
                pm = parse(Float64, currentLineData[5])
                # Update each array at index m 
                # Supports input being in random order of m 
                swellPressure[m] = sp 
                swellIndex[m] = cs
                compressionIndex[m] = cc
                maxPastPressure[m] = pm
            end
            # Increment last line index
            lastLineIndex += soilLayers
        end

        # Read M P0(M) P1(M) QC(M)
        pressureDilatometerA = zeros(Float64, soilLayers)
        pressureDilatometerB = zeros(Float64, soilLayers)
        conePenetrationResistance = zeros(Float64, soilLayers)
        if model == LeonardFrost
            for i in 1:soilLayers
                currentLineData = parseCurrentLine(input, 4, lastLineIndex+i)
                if currentLineData == -1
                    return
                end
                # Parse Data 
                m = parse(Int, currentLineData[1])
                pa = parse(Float64, currentLineData[2])
                pb = parse(Float64, currentLineData[3])
                qc = parse(Float64, currentLineData[4])
                # Update each array at index m 
                # Supports input being in random order of m 
                pressureDilatometerA[m] = pa 
                pressureDilatometerB[m] = pb 
                conePenetrationResistance[m] = qc
            end
            # Increment last line index
            lastLineIndex += soilLayers
        end

        # Read M QC(M)
        # Note: conePenetrationResistance already initialized above
        if model == Schmertmann
            for i in 1:soilLayers
                currentLineData = parseCurrentLine(input, 2, lastLineIndex+i)
                if currentLineData == -1
                    return
                end
                # Parse Data 
                m = parse(Int, currentLineData[1])
                qc = parse(Float64, currentLineData[2])
                # Update array at index m 
                # Supports input being in random order of m 
                conePenetrationResistance[m] = qc
            end
            # Increment last line index 
            lastLineIndex += soilLayers
        end

        # Read M PRES(M,5)
        # 5 values for each material, number of materials = soilLayers
        appliedPressureAtPoints = zeros(Float64, soilLayers, 5)
        if model == CollapsibleSoil
            for i in 1:soilLayers
                currentLineData = parseCurrentLine(input, 6, lastLineIndex+i)
                if currentLineData == -1
                    return 
                end
                # Parse data
                m = parse(Int, currentLineData[1])
                pressureA = parse(Float64, currentLineData[2])
                pressureBB = parse(Float64, currentLineData[3])
                pressureB = parse(Float64, currentLineData[4])
                pressureC = parse(Float64, currentLineData[5])
                pressureD = parse(Float64, currentLineData[6])
                # Update array at index m 
                # Supports input being in random order of m 
                appliedPressureAtPoints[m, 1] = pressureA
                appliedPressureAtPoints[m, 2] = pressureBB
                appliedPressureAtPoints[m, 3] = pressureB
                appliedPressureAtPoints[m, 4] = pressureC
                appliedPressureAtPoints[m, 5] = pressureD
            end
            lastLineIndex += soilLayers
        end

        # Read M ES(M)
        elasticModulus = zeros(Float64, soilLayers)
        if model == SchmertmannElastic
            for i in 1:soilLayers
                currentLineData = parseCurrentLine(input, 2, lastLineIndex+i)
                if currentLineData == -1
                    return
                end
                # Parse data 
                m = parse(Int, currentLineData[1])
                E = parse(Float64, currentLineData[2])
                # Update array at index m 
                # Supports input being in random order of m
                elasticModulus[m] = E
            end
            lastLineIndex += soilLayers
        end

        # Read XA XF
        # Since these values won't always be in input file 
        # but must always be passed into constructor, initialize
        # them in this scope
        heaveActiveZoneDepth = 0.0
        groundToHeaveDepth = 0.0
        if model == ConsolidationSwell
            currentLineData = parseCurrentLine(input, 2, lastLineIndex+2)
            if currentLineData == -1
                return
            end
            # Parse data
            heaveActiveZoneDepth = parse(Float64, currentLineData[1])
            groundToHeaveDepth = parse(Float64, currentLineData[2])
            # Increment last line index
            lastLineIndex += 1
        end

        # Read TIME 
        timeAfterConstruction = 0  # Won't always be read from input so init to 0 in this scope
        if model == Schmertmann || model == SchmertmannElastic
            currentLineData = parseCurrentLine(input, 1, lastLineIndex+1)
            # Parse data
            timeAfterConstruction = parse(Int, currentLineData[1])
            # Increment last line index
            lastLineIndex+=1
        end

        # Read M STRA(M,5)
        # 5 values for each material, number of materials = soilLayers
        strainAtPoints = zeros(Float64, soilLayers, 5)
        if model == CollapsibleSoil
            for i in 1:soilLayers
                currentLineData = parseCurrentLine(input, 6, lastLineIndex+i)
                if currentLineData == -1
                    return 
                end
                # Parse data
                m = parse(Int, currentLineData[1])
                strainA = parse(Float64, currentLineData[2])
                strainBB = parse(Float64, currentLineData[3])
                strainB = parse(Float64, currentLineData[4])
                strainC = parse(Float64, currentLineData[5])
                strainD = parse(Float64, currentLineData[6])
                # Update array at index m 
                # Supports input being in random order of m 
                strainAtPoints[m, 1] = strainA
                strainAtPoints[m, 2] = strainBB
                strainAtPoints[m, 3] = strainB
                strainAtPoints[m, 4] = strainC
                strainAtPoints[m, 5] = strainD
            end
            # Increment last line index
            lastLineIndex += soilLayers
        end

        new(problemName, numProblems, model, foundation, nodalPoints, elements, bottomPointIndex, soilLayers, dx, soilLayerNumber, specificGravity, waterContent, voidRatio, depthGroundWaterTable, equilibriumMoistureProfile, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, swellPressure, swellIndex, compressionIndex, maxPastPressure, pressureDilatometerA, pressureDilatometerB, conePenetrationResistance, appliedPressureAtPoints, elasticModulus, heaveActiveZoneDepth, groundToHeaveDepth, timeAfterConstruction, strainAtPoints)
    end
end

end # module
