module InputParser

# Julia implicitly numbers Enum items 0,1,2,3,4
@enum Model ConsolidationSwell LeonardFrost Schmertmann CollapsibleSoil SchmertmannElastic 
@enum Foundation ErrorFoundation RectangularSlab LongStripFooting 
@enum ErrorID ParsingErrorId FoundationErrorId SoilNumberErrorId NotEnoughValuesErrorId

#### Custom Exceptions  ################################

# ParsingError is for when we have already caught an error 
# in the body of InputData constructor, given user feedback, 
# but want to throw another error so caller of InputData 
# constructor can decide what to do
struct ParsingError <: Exception 
    id::Int
    ParsingError()=new(Int(ParsingErrorId))
end
Base.showerror(io::IO, e::ParsingError) = print(io, "Could not parse file.")

# FoundationError is for when foundationOption is not read as 1 or 2
struct FoundationError <: Exception 
    id::Int
    FoundationError()=new(Int(FoundationErrorId))
end
Base.showerror(io::IO, e::FoundationError) = print(io, "Incorrect option for foundation.")

# SoilNumberError is for when reading soilLayerNumber and invalid sequence given
struct SoilNumberError <: Exception
    id::Int 
    line::Int
end
Base.showerror(io::IO, e::SoilNumberError) = print(io, "Invalid soil layer number value on line $(e.line)!")

# NotEnoughValuesError is for the parseCurrentLine function
# If given line doesn't have as many values as expected, this error
# is thrown
struct NotEnoughValuesError <: Exception 
    id::Int
    requiredValues::Int
    givenValues::Int
    line::Int
end
Base.showerror(io::IO, e::NotEnoughValuesError) = print(io, "Invalid input file!\n\t>Line $(e.line): $(e.requiredValues) values expected, only given $(e.givenValues)!")
########################################################

# These are variables/objects visible to all modules
# that include InputParser module
export Model, Foundation, ErrorID, InputData, ParsingError, SoilNumberError

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
        throw(NotEnoughValuesError(Int(NotEnoughValuesErrorId), items, size(currentLineData)[1], index))
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
    dx::Array{Float64}
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
    totalDepth::Float64
    foundationDepth::Float64

    # Parses input file at filePath and returns corresponding InputData object
    function InputData(filePath::String)
        input = open(filePath) do file
            readlines(file)
        end

        # Only allow lines that have non empty space chars
        input_not_empty = filter(contains(r"[^\s]"), input)
        # Remove comments
        input = [] # Reinitialize array of lines
        for line in input_not_empty
            # Split at comment
            line_split = split(line, "#")
            # Add all data before comment to output
            push!(input, line_split[1])
        end
        # Get rid of empty lines (these lines only contained comments before)
        input::Array{String} = filter(contains(r"[^\s]"), input)
        # For some reason, not explicitly typing this caused errors

        # Keep track of last line read
        lastLineIndex = 0

        # Get title of problem
        problemName = input[lastLineIndex+1]
        lastLineIndex += 1

        # Get following data:
        #  NPROB NOPT NBPRES NNP NBX NMAT 
        dataLine1 = []
        try
            dataLine1 = parseCurrentLine(input, 6, lastLineIndex+1)
        catch e
            if isa(e, NotEnoughValuesError)
                println("Error: Invalid input file!")
                println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                throw(ParsingError())
            end
        end

        # Parse each value
        numProblems = 0
        model = CollapsibleSoil
        try
            numProblems = parse(Int64, dataLine1[1])
            modelOption = parse(Int64, dataLine1[2])
            model = Model(modelOption) # Int -> Enum conversion
        catch e 
            if isa(e, ArgumentError)
                println("Error, invalid value on line $(lastLineIndex+1)!")
            elseif isa(e, BoundsError)
                # File ran out of lines
                println("Error, encountered end of file unexpectedly!")
            else
                # Some other problem
                println("Unexpected error occured while reading file at $(filePath)")
            end
            throw(ParsingError())
        end

        foundation = ErrorFoundation
        try
            foundationOption = parse(Int64, dataLine1[3]) # Rectangular Slab or Long Strip Footing
            foundation = (foundationOption == 1) ? RectangularSlab : (foundationOption == 2) ? LongStripFooting : throw(FoundationError())
        catch e 
            if isa(e, ArgumentError)
                println("Error, invalid value on line $(lastLineIndex+1)!")
            elseif isa(e, BoundsError)
                # File ran out of lines
                println("Error, encountered end of file unexpectedly!")
            elseif isa(e, FoundationError)
                println("Error, illegal foundation option $(foundationOption). Must be 1 or 2!")
            else
                # Some other problem
                println("Unexpected error occured while reading file at $(filePath)!")
            end
            throw(ParsingError())
        end

        nodalPoints = 0
        elements = 0
        bottomPointIndex = 0
        soilLayers = 0
        
        try
            nodalPoints = parse(Int64, dataLine1[4])
            elements = nodalPoints - 1
            bottomPointIndex = parse(Int64, dataLine1[5])
            soilLayers = parse(Int64, dataLine1[6]) # NMAT
        catch e 
            if isa(e, ArgumentError)
                println("Error, invalid value on line $(lastLineIndex+1)!")
            elseif isa(e, BoundsError)
                # File ran out of lines
                println("Error, encountered end of file unexpectedly!")
            else
                # Some other problem
                println("Unexpected error occured while reading file at $(filePath)!")
            end
            throw(ParsingError())
        end
        
        lastLineIndex += 1

        # DX array
        dx = Array{Float64}(undef, soilLayers)
        dataLine1 = []
        try
            dataLine1 = parseCurrentLine(input, soilLayers, lastLineIndex+1)
        catch e
            if isa(e, NotEnoughValuesError)
                println("Error: Invalid input file!")
                println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                throw(ParsingError())
            end
        end
        try
            for i = 1:soilLayers
                dx[i] = parse(Float64, dataLine1[i])
            end
        catch e 
            if isa(e, ArgumentError)
                println("Error, invalid value on line $(lastLineIndex+1)!")
            elseif isa(e, BoundsError)
                # File ran out of lines
                println("Error, encountered end of file unexpectedly!")
            else
                # Some other problem
                println("Unexpected error occured while reading file at $(filePath)!")
            end
            throw(ParsingError())
        end
        lastLineIndex += 1

        # Soil layer number of element N
        soilLayerNumber = []  # Array IE(N,M) from FORTRAN Code
        lastElement = -1 # Index of last element we saw
        lastLayerNum = -1 # Last layerNum we saw
        for i in 1:soilLayers+1  # For each layer + last line that has NEL NMAT
            # Get current line and its data
            currentLineData = []
            try
                currentLineData = parseCurrentLine(input, 2, lastLineIndex + 1)
            catch
                if isa(e, NotEnoughValuesError)
                    println("Error: Invalid input file!")
                    println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                    throw(ParsingError())
                end
            end
            # Update last line read
            lastLineIndex += 1

            element = 0
            layerNum = 0
            try
                # element is first value
                element = parse(Int32, currentLineData[1])
                # layer number is second value
                layerNum = parse(Int32, currentLineData[2])
            catch e
                if isa(e, ArgumentError)
                    println("Error, invalid value on line $(lastLineIndex+1)!")
                elseif isa(e, BoundsError)
                    # File ran out of lines
                    println("Error, encountered end of file unexpectedly!")
                else
                    # Some other problem
                    println("Unexpected error occured while reading file at $(filePath)!")
                end
                throw(ParsingError())
            end

            if lastElement == -1  # We haven't seen an element before
                # push first layerNum value
                push!(soilLayerNumber, layerNum)
            else   # We have seen element before
                # This lines element must be larger than previous lines
                if element <= lastElement
                    throw(SoilNumberError(Int(SoilNumberErrorId), lastLineIndex+1))
                end
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
            currentLineData = []
            try
                currentLineData = parseCurrentLine(input, 4, lastLineIndex + i)
            catch e
                if isa(e, NotEnoughValuesError)
                    println("Error: Invalid input file!")
                    println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                    throw(ParsingError())
                end
            end

            try
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
            catch e
                if isa(e, ArgumentError)
                    println("Error, invalid value on line $(lastLineIndex+1)!")
                elseif isa(e, BoundsError)
                    # File ran out of lines
                    println("Error, encountered end of file unexpectedly!")
                else
                    # Some other problem
                    println("Unexpected error occured while reading file at $(filePath)!")
                end
                throw(ParsingError())
            end
        end
        # Increment last line to last line of material properties
        lastLineIndex += soilLayers

        # Read DGWT IOPTION NOUT
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, 3, lastLineIndex+1)
        catch e
            if isa(e, NotEnoughValuesError)
                println("Error: Invalid input file!")
                println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                throw(ParsingError())
            end
        end
        # Parse data
        depthGroundWaterTable = 0.0
        equilibriumMoistureProfile = true
        outputIncrements = false
        try
            depthGroundWaterTable = parse(Float64, currentLineData[1])
            equilibriumMoistureProfileOption = parse(Int8, currentLineData[2])
            if !(equilibriumMoistureProfileOption == 1) && !(equilibriumMoistureProfileOption == 0)
                println("Warning: Invalid input on line $(lastLineIndex+1)")
                println("\tExpected either 0 or 1 for equilibriumMoistureProfileOption")
            end
            equilibriumMoistureProfile = (equilibriumMoistureProfileOption == 1) ? true : false
            outputIncrementsOption = parse(Int8, currentLineData[3])
            if !(outputIncrementsOption == 1) && !(outputIncrementsOption == 0)
                println("Warning: Invalid input on line $(lastLineIndex+1)")
                println("\tExpected either 0 or 1 for outputIncrementsOption")
            end
            outputIncrements = (outputIncrementsOption == 1) ? true : false
        catch e
            if isa(e, ArgumentError)
                println("Error, invalid value on line $(lastLineIndex+1)!")
            elseif isa(e, BoundsError)
                # File ran out of lines
                println("Error, encountered end of file unexpectedly!")
            else
                # Some other problem
                println("Unexpected error occured while reading file at $(filePath)!")
            end
            throw(ParsingError())
        end
        # Increment last line index 
        lastLineIndex += 1

        # Read Q BLEN BWID MRECT
        try
            currentLineData = parseCurrentLine(input, 4, lastLineIndex+1)
        catch e
            if isa(e, NotEnoughValuesError)
                println("Error: Invalid input file!")
                println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                throw(ParsingError())
            end
        end
        # Parse data
        appliedPressure = 0.0
        foundationLength = 0.0
        foundationWidth = 0.0
        center = true
        try
            appliedPressure = parse(Float64, currentLineData[1])
            foundationLength = parse(Float64, currentLineData[2])
            foundationWidth = parse(Float64, currentLineData[3])
            forcePointOption = parse(Int, currentLineData[4])
            if !(forcePointOption == 1) && !(forcePointOption == 0)
                println("Warning: Invalid input on line $(lastLineIndex+1)")
                println("\tExpected either 0 or 1 for forcePointOption!")
            end
            center = (forcePointOption == 1) ? false : true
        catch e
            if isa(e, ArgumentError)
                println("Error, invalid value on line $(lastLineIndex+1)!")
            elseif isa(e, BoundsError)
                # File ran out of lines
                println("Error, encountered end of file unexpectedly!")
            else
                # Some other problem
                println("Unexpected error occured while reading file at $(filePath)!")
            end
            throw(ParsingError())
        end
        # Increment last line index
        lastLineIndex += 1

        # Read M SP(M) CS(M) CC(M) PM(M)
        swellPressure = zeros(Float64, soilLayers)
        swellIndex = zeros(Float64, soilLayers)
        compressionIndex = zeros(Float64, soilLayers)
        maxPastPressure = zeros(Float64, soilLayers)
        if model == ConsolidationSwell
            for i in 1:soilLayers
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 5, lastLineIndex + i)
                catch e
                    if isa(e, NotEnoughValuesError)
                        println("Error: Invalid input file!")
                        println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                        throw(ParsingError())
                    end
                end
                try
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
                catch e
                    if isa(e, ArgumentError)
                        println("Error, invalid value on line $(lastLineIndex+1)!")
                    elseif isa(e, BoundsError)
                        # File ran out of lines
                        println("Error, encountered end of file unexpectedly!")
                    else
                        # Some other problem
                        println("Unexpected error occured while reading file at $(filePath)!")
                    end
                    throw(ParsingError())
                end
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
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 4, lastLineIndex+i)
                catch e
                    if isa(e, NotEnoughValuesError)
                        println("Error: Invalid input file!")
                        println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                        throw(ParsingError())
                    end
                end
            
                try
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
                catch e
                    if isa(e, ArgumentError)
                        println("Error, invalid value on line $(lastLineIndex+1)!")
                    elseif isa(e, BoundsError)
                        # File ran out of lines
                        println("Error, encountered end of file unexpectedly!")
                    else
                        # Some other problem
                        println("Unexpected error occured while reading file at $(filePath)!")
                    end
                    throw(ParsingError())
                end
            end
            # Increment last line index
            lastLineIndex += soilLayers
        end

        # Read M QC(M)
        if model == Schmertmann
            # Reinitialize to larger array if schemrtmann method
            conePenetrationResistance = zeros(Float64, soilLayers+1)
            for i in 1:soilLayers
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 2, lastLineIndex+i)
                catch e
                    if isa(e, NotEnoughValuesError)
                        println("Error: Invalid input file!")
                        println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                        throw(ParsingError())
                    end
                end

                try
                    # Parse Data 
                    m = parse(Int, currentLineData[1])
                    qc = parse(Float64, currentLineData[2])
                    # Update array at index m 
                    # Supports input being in random order of m 
                    conePenetrationResistance[m] = qc
                catch e
                    if isa(e, ArgumentError)
                        println(" Error, invalid value on line $(lastLineIndex+1)!")
                    elseif isa(e, BoundsError)
                        # File ran out of lines
                        println("Error, encountered end of file unexpectedly!")
                    else
                        # Some other problem
                        println("Unexpected error occured while reading file at $(filePath)!")
                    end
                    throw(ParsingError())
                end
            end
            # Increment last line index 
            lastLineIndex += soilLayers
        end

        # Read M PRES(M,5)
        # 5 values for each material, number of materials = soilLayers
        appliedPressureAtPoints = zeros(Float64, soilLayers, 5)
        if model == CollapsibleSoil
            for i in 1:soilLayers
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 6, lastLineIndex+i)
                catch e
                    if isa(e, NotEnoughValuesError)
                        println("Error: Invalid input file!")
                        println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                        throw(ParsingError())
                    end
                end

                try
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
                catch e
                    if isa(e, ArgumentError)
                        println("Error, invalid value on line $(lastLineIndex+1)!")
                    elseif isa(e, BoundsError)
                        # File ran out of lines
                        println("Error, encountered end of file unexpectedly!")
                    else
                        # Some other problem
                        println("Unexpected error occured while reading file at $(filePath)!")
                    end
                    throw(ParsingError())
                end
            end
            lastLineIndex += soilLayers
        end

        # Read M ES(M)
        elasticModulus = zeros(Float64, soilLayers)
        if model == SchmertmannElastic
            for i in 1:soilLayers
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 2, lastLineIndex+i)
                catch e 
                    if isa(e, NotEnoughValuesError)
                        println("Error: Invalid input file!")
                        println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                        throw(ParsingError())
                    end
                end

                try
                    # Parse data 
                    m = parse(Int, currentLineData[1])
                    E = parse(Float64, currentLineData[2])
                    # Update array at index m 
                    # Supports input being in random order of m
                    elasticModulus[m] = E
                catch e 
                    if isa(e, ArgumentError)
                        println("Error, invalid value on line $(lastLineIndex+1)!")
                    elseif isa(e, BoundsError)
                        # File ran out of lines
                        println("Error, encountered end of file unexpectedly!")
                    else
                        # Some other problem
                        println("Unexpected error occured while reading file at $(filePath)!")
                    end
                    throw(ParsingError())
                end
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
            currentLineData = []
            try
                currentLineData = parseCurrentLine(input, 2, lastLineIndex+1)
            catch e
                if isa(e, NotEnoughValuesError)
                    println("Error: Invalid input file!")
                    println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                    throw(ParsingError())
                end
            end

            try
                # Parse data
                heaveActiveZoneDepth = parse(Float64, currentLineData[1])
                groundToHeaveDepth = parse(Float64, currentLineData[2])
            catch e
                if isa(e, ArgumentError)
                    println("Error, invalid value on line $(lastLineIndex+1)!")
                elseif isa(e, BoundsError)
                    # File ran out of lines
                    println("Error, encountered end of file unexpectedly!")
                else
                    # Some other problem
                    println("Unexpected error occured while reading file at $(filePath)!")
                end
                throw(ParsingError())
            end
            # Increment last line index
            lastLineIndex += 1
        end

        # Read TIME 
        timeAfterConstruction = 0  # Won't always be read from input so init to 0 in this scope
        if model == Schmertmann || model == SchmertmannElastic
            currentLineData = []
            try
                currentLineData = parseCurrentLine(input, 1, lastLineIndex+1)
            catch e 
                if isa(e, NotEnoughValuesError)
                    println("Error: Invalid input file!")
                    println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                    throw(ParsingError())
                end
            end
            # Parse data
            try
                timeAfterConstruction = Int(floor(parse(Float64, currentLineData[1])))
            catch e
                if isa(e, ArgumentError)
                    println("Error, invalid value on line $(lastLineIndex+1)!")
                elseif isa(e, BoundsError)
                    # File ran out of lines
                    println("Error, encountered end of file unexpectedly!")
                else
                    # Some other problem
                    println("Unexpected error occured while reading file at $(filePath)!")
                end
                throw(ParsingError())
            end
            # Increment last line index
            lastLineIndex+=1
        end

        # Read M STRA(M,5)
        # 5 values for each material, number of materials = soilLayers
        strainAtPoints = zeros(Float64, soilLayers, 5)
        if model == CollapsibleSoil
            for i in 1:soilLayers
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 6, lastLineIndex+i)
                catch e 
                    if isa(e, NotEnoughValuesError)
                        println("Error: Invalid input file!")
                        println("\t>Line $(e.line): $(e.requiredValues) values expected!")
                        throw(ParsingError())
                    end
                end

                try 
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
                catch e
                    if isa(e, ArgumentError)
                        println("Error, invalid value on line $(lastLineIndex+1)!")
                    elseif isa(e, BoundsError)
                        # File ran out of lines
                        println("Error, encountered end of file unexpectedly!")
                    else
                        # Some other problem
                        println("Unexpected error occured while reading file at $(filePath)!")
                    end
                    throw(ParsingError())
                end
            end
            # Increment last line index
            lastLineIndex += soilLayers
        end

        # Calculate total depth and foundation depth
        totalDepth = 0
        for i = 1:elements
            totalDepth += dx[soilLayerNumber[i]]
        end
        foundationDepth = 0
        for i = 1:bottomPointIndex-1
            foundationDepth += dx[soilLayerNumber[i]]
        end

        new(problemName, numProblems, model, foundation, nodalPoints, elements, bottomPointIndex, soilLayers, dx, soilLayerNumber, specificGravity, waterContent, voidRatio, depthGroundWaterTable, equilibriumMoistureProfile, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, swellPressure, swellIndex, compressionIndex, maxPastPressure, pressureDilatometerA, pressureDilatometerB, conePenetrationResistance, appliedPressureAtPoints, elasticModulus, heaveActiveZoneDepth, groundToHeaveDepth, timeAfterConstruction, strainAtPoints, totalDepth, foundationDepth)
    end
end

end # module
