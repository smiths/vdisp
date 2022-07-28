module InputParser

# Julia implicitly numbers Enum items 0,1,2,3,4
@enum Model ConsolidationSwell LeonardFrost Schmertmann CollapsibleSoil SchmertmannElastic 
@enum Foundation ErrorFoundation RectangularSlab LongStripFooting 
@enum ErrorID ParsingErrorId FoundationErrorId SoilNumberErrorId NotEnoughValuesErrorId ModelErrorId FoundationTypeErrorId FloatConvertErrorId DimensionNegativeErrorId IntConvertErrorId UnitErrorId BoolConvertErrorId MaterialIndexOutOfBoundsErrorId PropertyErrorId
@enum Units Metric Imperial

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

# ModelError is thrown when user enters invalid number for model in input file
struct ModelError <: Exception
    id::Int32
    line::Int32
    value::String
    ModelError(line::Int32, value::String)=new(Int(ModelErrorId), line, value)
end
Base.showerror(io::IO, e::ModelError) = print(io, "Line $(e.line): Model input should be 0, 1 or 2. Input was $(e.value)")

# UnitError is thrown when user enters invalid number for unit in input file
struct UnitError <: Exception
    id::Int32
    line::Int32
    value::String
    UnitError(line::Int32, value::String)=new(Int(UnitErrorId), line, value)
end
Base.showerror(io::IO, e::UnitError) = print(io, "Line $(e.line): Unit input should be 0, or 1. Input was $(e.value)")

# FoundationTypeError is thrown when user enters invalid number for foundation in input file
struct FoundationTypeError <: Exception
    id::Int32
    line::Int32
    value::String
    FoundationTypeError(line::Int32, value::String)=new(Int(FoundationTypeErrorId), line, value)
end
Base.showerror(io::IO, e::FoundationTypeError) = print(io, "Line $(e.line): Foundation input should be 0 or 1. Input was $(e.value)")

# Anytime a variable that was supposed to be floating point number has trouble parsing
struct FloatConvertError <: Exception
    id::Int32
    line::Int32
    var::String
    value::String
    FloatConvertError(line::Int32, var::String, value::String) = new(Int(FloatConvertErrorId), line, var, value)
end
Base.showerror(io::IO, e::FloatConvertError) = print(io, "Line $(e.line): $(e.var) value should be a valid float value. Trouble parsing input \"$(e.value)\"")

# Anytime a variable that was supposed to be an integer number has trouble parsing
struct IntConvertError <: Exception
    id::Int32
    line::Int32
    var::String
    value::String
    IntConvertError(line::Int32, var::String, value::String) = new(Int(FloatConvertErrorId), line, var, value)
end
Base.showerror(io::IO, e::IntConvertError) = print(io, "Line $(e.line): $(e.var) value should be a valid integer value. Trouble parsing input \"$(e.value)\"")

# Anytime a variable that was supposed to be a boolean has trouble parsing
struct BoolConvertError <: Exception
    id::Int32
    line::Int32
    var::String
    value::String
    BoolConvertError(line::Int32, var::String, value::String) = new(Int(BoolConvertErrorId), line, var, value)
end
Base.showerror(io::IO, e::BoolConvertError) = print(io, "Line $(e.line): $(e.var) value should be a 0(false) or 1(true). Trouble parsing input \"$(e.value)\"")

# Anytime a dimension variable was negative
struct DimensionNegativeError <: Exception 
    id::Int32
    line::Int32
    var::String
    value::String
    DimensionNegativeError(line::Int32, var::String, value::String) = new(Int(DimensionNegativeErrorId), line, var, value)
end
Base.showerror(io::IO, e::DimensionNegativeError) = print(io, "Line $(e.line): $(e.var) value should be positive. Input was \"$(e.value)\"")

# When material index is out of bounds
struct MaterialIndexOutOfBoundsError <: Exception
    id::Int32
    line::Int32
    value::String
    MaterialIndexOutOfBoundsError(line::Int32, value::String) = new(Int(MaterialIndexOutOfBoundsErrorId), line, value)
end
Base.showerror(io::IO, e::MaterialIndexOutOfBoundsError) = print(io, "Line $(e.line): Invalid material index \"$(e.value)\"")

struct PropertyError <: Exception
    id::Int32
    msg::String
    PropertyError(msg::String) = new(Int(PropertyErrorId), msg)
end
Base.showerror(io::IO, e::PropertyError) = print(io, e.msg)
########################################################

# These are variables/objects visible to all modules
# that include InputParser module
export Model, Units, Foundation, ErrorID, GUIData, InputData, ParsingError, SoilNumberError, ModelError, UnitError, FoundationTypeError, FloatConvertError, IntConvertError, BoolConvertError, DimensionNegativeError, MaterialIndexOutOfBoundsError, PropertyError

"""
    parseCurrentLine(input, items, index)

Parses the string and *index*-th index of *input* array. Makes sure there are *items*
values separated by spaces in the string. 
"""
function parseCurrentLine(input::Array{String}, items::Int, index::Int, splitString::String=" ")
    currentLine = input[index]
    # Tabs ruin splitting by space
    currentLine = replace(currentLine, "\t" => " ")
    currentLineData = split(currentLine, splitString)
    currentLineData = filter(x -> x != "", currentLineData)
    # Check if data is there
    if size(currentLineData)[1] < items
        throw(NotEnoughValuesError(Int(NotEnoughValuesErrorId), items, size(currentLineData)[1], index))
    end
    return currentLineData
end

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
    materialNames::Array{String}
    units::Int

    # Creates InputData instance from ConsolidationSwell data gathered from QML GUI. Normally called directly from OutputData instance
    function InputData(problemName::String, foundationType::String, materialCount::Int32, dx::Array{Float64}, soilLayerNumbers::Array{Int32}, nodalPoints::Int32, elements::Int32, materialNames::Array{String}, specificGravity::Array{Float64}, voidRatio::Array{Float64}, waterContent::Array{Float64}, subdivisions::Array{Int32}, swellPressure::Array{Float64}, swellIndex::Array{Float64}, compressionIndex::Array{Float64}, maxPastPressure::Array{Float64}, foundationIndex::Int32, depthGroundWaterTable::Float64, saturatedAboveWaterTable::Bool, outputIncrements::Bool, appliedPressure::Float64, foundationLength::Float64, foundationWidth::Float64, center::Bool, heaveActive::Float64, heaveBegin::Float64, totalDepth::Float64, foundationDepth::Float64, units::Int32)
        model::Model = ConsolidationSwell
        foundation::Foundation = (foundationType == "RectangularSlab") ? RectangularSlab : LongStripFooting
        return new(problemName, 1, model, foundation, nodalPoints, elements, foundationIndex, materialCount, dx, soilLayerNumbers, specificGravity, waterContent, voidRatio, depthGroundWaterTable, saturatedAboveWaterTable, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, swellPressure, swellIndex, compressionIndex, maxPastPressure, Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64, 2}(undef, 0, 0), Array{Float64}(undef, 0), heaveActive, heaveBegin, 0, Array{Float64, 2}(undef, 0, 0), totalDepth, foundationDepth, materialNames, units)
    end

    # Creates InputData instance from Schmertmann data gathered from QML GUI. Normally called directly from OutputData instance
    function InputData(problemName::String, foundationType::String, materialCount::Int32, dx::Array{Float64}, soilLayerNumbers::Array{Int32}, nodalPoints::Int32, elements::Int32, materialNames::Array{String}, specificGravity::Array{Float64}, voidRatio::Array{Float64}, waterContent::Array{Float64}, subdivisions::Array{Int32}, conePenetrationResistance::Array{Float64},foundationIndex::Int32, depthGroundWaterTable::Float64, saturatedAboveWaterTable::Bool, outputIncrements::Bool, appliedPressure::Float64, foundationLength::Float64, foundationWidth::Float64, center::Bool, heaveActive::Float64, heaveBegin::Float64, totalDepth::Float64, foundationDepth::Float64, timeAfterConstruction::Int32, units::Int32)
        model::Model = Schmertmann
        foundation::Foundation = (foundationType == "RectangularSlab") ? RectangularSlab : LongStripFooting
        return new(problemName, 1, model, foundation, nodalPoints, elements, foundationIndex, materialCount, dx, soilLayerNumbers, specificGravity, waterContent, voidRatio, depthGroundWaterTable, saturatedAboveWaterTable, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), conePenetrationResistance, Array{Float64, 2}(undef, 0, 0), Array{Float64}(undef, 0), heaveActive, heaveBegin, timeAfterConstruction, Array{Float64, 2}(undef, 0, 0), totalDepth, foundationDepth, materialNames, units)
    end
    
    # Creates InputData instance from SchmertmannElastic data gathered from QML GUI. Normally called directly from OutputData instance
    function InputData(problemName::String, foundationType::String, materialCount::Int32, dx::Array{Float64}, soilLayerNumbers::Array{Int32}, nodalPoints::Int32, elements::Int32, materialNames::Array{String}, specificGravity::Array{Float64}, voidRatio::Array{Float64}, waterContent::Array{Float64}, subdivisions::Array{Int32},foundationIndex::Int32, depthGroundWaterTable::Float64, saturatedAboveWaterTable::Bool, outputIncrements::Bool, appliedPressure::Float64, foundationLength::Float64, foundationWidth::Float64, center::Bool, heaveActive::Float64, heaveBegin::Float64, totalDepth::Float64, foundationDepth::Float64, elasticModulus::Array{Float64}, timeAfterConstruction::Int32, units::Int32)
        model::Model = SchmertmannElastic
        foundation::Foundation = (foundationType == "RectangularSlab") ? RectangularSlab : LongStripFooting
        return new(problemName, 1, model, foundation, nodalPoints, elements, foundationIndex, materialCount, dx, soilLayerNumbers, specificGravity, waterContent, voidRatio, depthGroundWaterTable, saturatedAboveWaterTable, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, 0), Array{Float64}(undef, materialCount), Array{Float64, 2}(undef, 0, 0), elasticModulus, heaveActive, heaveBegin, timeAfterConstruction, Array{Float64, 2}(undef, 0, 0), totalDepth, foundationDepth, materialNames, units)
    end

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

        # materialNames = Array{String}(undef, soilLayers)
        # for i in 1:soilLayers
        #     # Default name for ith material is "Material i" 
        #     materialNames[i] = "Material " * string(i)
        # end
        # Material names array
        materialNames::Array{String} = ["Material " * string(i) for i in 1:soilLayers]

        new(problemName, numProblems, model, foundation, nodalPoints, elements, bottomPointIndex, soilLayers, dx, soilLayerNumber, specificGravity, waterContent, voidRatio, depthGroundWaterTable, equilibriumMoistureProfile, outputIncrements, appliedPressure, foundationLength, foundationWidth, center, swellPressure, swellIndex, compressionIndex, maxPastPressure, pressureDilatometerA, pressureDilatometerB, conePenetrationResistance, appliedPressureAtPoints, elasticModulus, heaveActiveZoneDepth, groundToHeaveDepth, timeAfterConstruction, strainAtPoints, totalDepth, foundationDepth, materialNames, Int(Imperial))
    end
end

struct GUIData
    # Stage 1
    problemName::String
    model::Int32 
    units::Int32
    foundation::Int32
    appliedAt::Int32
    foundationWidth::Float64
    foundationLength::Float64
    appliedPressure::Float64
    outputIncrements::Bool
    saturatedAboveWaterTable::Bool
    # Stage 2
    materials::Int32
    materialNames::Array{String}
    specificGravity::Array{Float64}
    voidRatio::Array{Float64}
    waterContent::Array{Float64}
    # Stage 3
    totalDepth::Float64
    depthGroundWaterTable::Float64
    foundationDepth::Float64
    subdivisions::Array{Int32}
    soilLayerNumbers::Array{Int32}
    bounds::Array{Float64}
    # Stage 4
    heaveBeginDepth::Float64
    heaveActiveDepth::Float64
    swellPressure::Array{Float64}
    swellIndex::Array{Float64}
    compressionIndex::Array{Float64}
    maxPastPressure::Array{Float64}
    timeAfterConstruction::Int32
    elasticModulus::Array{Float64}
    conePenetration::Array{Float64}

    function GUIData(filePath::String)
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
        
        # First line is problem name
        problemName = input[1]
        lastLineIndex = 1

        # Read model, units
        model = 0
        units = 0
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, 2, lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        try 
            model = parse(Int32, currentLineData[1])
        catch e
            throw(IntConvertError(lastLineIndex+1, "model", currentLineData[1]))
        end
        if model > 2 || model < 0
            throw(ModelError(lastLineIndex+1, currentLineData[1]))
        end
        try
            units = parse(Int32, currentLineData[2])
        catch e
            throw(IntConvertError(lastLineIndex+1, "units", currentLineData[2]))
        end
        if units > 1 || units < 0
            throw(UnitError(lastLineIndex+1, currentLineData[2]))
        end
        lastLineIndex+=1

        # Read foundation type, width, length 
        foundationType = 0
        foundationWidth = 0.0
        foundationLength = 0.0
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, 3, lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        try
            foundationType = parse(Int32, currentLineData[1])
        catch e
            throw(IntConvertError(lastLineIndex+1,"foundation type",currentLineData[1]))
        end
        if foundationType < 0 || foundationType > 1
            throw(FoundationTypeError(lastLineIndex+1,currentLineData[1]))
        end
        try 
            foundationWidth = parse(Float64, currentLineData[2])
        catch e
            throw(FloatConvertError(lastLineIndex+1,"foundation width",currentLineData[2]))
        end
        if foundationWidth < 0
            throw(DimensionNegativeError(lastLineIndex+1,"foundation width",currentLineData[2]))
        end
        try 
            foundationLength = parse(Float64, currentLineData[3])
        catch e
            throw(FloatConvertError(lastLineIndex+1,"foundation length",currentLineData[3]))
        end
        if foundationLength < 0
            throw(DimensionNegativeError(lastLineIndex+1,"foundation length",currentLineData[3]))
        end
        lastLineIndex += 1

        # Read applied pressure and applied at
        appliedPressure = 0.0
        appliedAt = 0
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, 2, lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        try 
            appliedPressure = parse(Float64, currentLineData[1])
        catch e
            throw(FloatConvertError(lastLineIndex+1,"applied pressure",currentLineData[1]))
        end
        if appliedPressure < 0
            throw(DimensionNegativeError(lastLineIndex+1,"applied pressure",currentLineData[1]))
        end
        try
            appliedAt = parse(Int32, currentLineData[2])
        catch e
            throw(IntConvertError(lastLineIndex+1, "applied at", currentLineData[2]))
        end
        if appliedAt < 0
            appliedAt = 0
            println("Warning: \"applied at\" value was less than 0, but it was changed to 0")
        end
        if appliedAt > 2
            appliedAt = 2
            println("Warning: \"applied at\" value was greater than 2, but it was changed to 2")
        end
        lastLineIndex += 1

        # Read OutputIncrements and Saturated above water table
        outputIncrements = false
        saturatedAboveWaterTable = false
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, 2, lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        try
            outputIncrements = parse(Bool, currentLineData[1])
        catch e
            throw(BoolConvertError(lastLineIndex+1, "output increments", currentLineData[1]))
        end
        try
            saturatedAboveWaterTable = parse(Bool, currentLineData[2])
        catch e
            throw(BoolConvertError(lastLineIndex+1, "saturated above water table", currentLineData[2]))
        end
        lastLineIndex += 1

        # Read number of materials
        materials = 0
        try
            materials = parse(Int32, input[lastLineIndex+1])
        catch e
            throw(IntConvertError(lastLineIndex+1, "number of materials", input[lastLineIndex+1]))
        end
        lastLineIndex += 1

        # Read material names, specific gravity, void ratio, water content
        materialNames = Array{String}(undef, materials)
        specificGravity = Array{Float64}(undef, materials)
        voidRatio = Array{Float64}(undef, materials)
        waterContent = Array{Float64}(undef, materials)
        for i=1:materials
            currentLineData = []
            try
                currentLineData = parseCurrentLine(input, 5, lastLineIndex+i, ",")
            catch e
                throw(e)
            end
            m = 0
            try 
                m = parse(Int32, currentLineData[1])
            catch e
                throw(IntConvertError(lastLineIndex+i, "material index $i",currentLineData[1]))
            end
            if m < 1 || m > materials
                throw(MaterialIndexOutOfBoundsError(lastLineIndex+i, currentLineData[1]))
            end
            name = currentLineData[2]
            sg = 0.0
            try
                sg = parse(Float64, currentLineData[3])
            catch e 
                throw(FloatConvertError(lastLineIndex+i, "specific gravity of material $i", currentLineData[3]))
            end
            if sg < 0
                throw(PropertyError("Line $(lastLineIndex+i): Specific gravity cannot be negative"))
            end
            vr = 0.0
            try
                vr = parse(Float64, currentLineData[4])
            catch e 
                throw(FloatConvertError(lastLineIndex+i, "void ratio of material $i", currentLineData[4]))
            end
            if vr < 0
                throw(PropertyError("Line $(lastLineIndex+i): Void ratio cannot be negative"))
            end
            wc = 0.0
            try
                wc = parse(Float64, currentLineData[5])
            catch e 
                throw(FloatConvertError(lastLineIndex+i, "water content of material $i", currentLineData[5]))
            end
            if wc < 0 || wc > 100
                throw(PropertyError("Line $(lastLineIndex+i): Water content must be in range [0, 100]"))
            end
            
            materialNames[m] = name
            specificGravity[m] = sg
            waterContent[m] = wc
            voidRatio[m] = vr
        end
        lastLineIndex += materials

        # Read Total Depth
        totalDepth = 0.0
        try 
            totalDepth = parse(Float64, input[lastLineIndex+1])
        catch e
            throw(FloatConvertError(lastLineIndex+1, "total depth of soil profile", input[lastLineIndex+1]))
        end
        if totalDepth <= 0
            throw(PropertyError("Line $(lastLineIndex+1): Total depth must be greater than 0"))
        end
        lastLineIndex += 1

        # Read Depth to Foundation, Depth to Ground Water Table
        foundationDepth = 0.0
        depthGroundWaterTable = 0.0
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, 2, lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        try
            foundationDepth = parse(Float64, currentLineData[1])
        catch
            throw(FloatConvertError(lastLineIndex+1, "foundation depth", currentLineData[1]))
        end
        if foundationDepth < 0 || foundationDepth > totalDepth
            throw(PropertyError("Line $(lastLineIndex+1): Foundation Depth must be greater than 0 and less than the total depth"))
        end
        try
            depthGroundWaterTable = parse(Float64, currentLineData[2])
        catch
            throw(FloatConvertError(lastLineIndex+1, "depth to ground water table", currentLineData[2]))
        end
        if depthGroundWaterTable < 0 || depthGroundWaterTable > totalDepth
            throw(PropertyError("Line $(lastLineIndex+1): Depth to Ground Water Table must be greater than 0 and less than the total depth"))
        end
        lastLineIndex += 1

        # Read bounds (size of bounds: #handles + 2 = #materials-1 + 2 = #materials + 1)
        bounds = Array{Float64}(undef, materials+1)
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, materials+1, lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        for i=1:materials+1
            b = 0.0
            try
                b = parse(Float64, currentLineData[i])
            catch e
                throw(FloatConvertError(lastLineIndex+1, "bounds[$i]", currentLineData[i]))
            end
            if i == 0 && b != 0.0
                throw(PropertyError("Line $(lastLineIndex+1): First entry of bounds must be 0"))
            end
            if i == materials+1 && b != totalDepth
                throw(PropertyError("Line $(lastLineIndex+1): Last entry of bounds must be the total depth"))
            end
            bounds[i] = b
        end
        lastLineIndex += 1

        # Read soil layer numbers
        soilLayerNumbers = Array{Int32}(undef, materials)
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, Int64(materials), lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        for i=1:materials
            n = 0
            try
                n = parse(Int32, currentLineData[i])
            catch e
                throw(IntConvertError(lastLineIndex+1, "Soil Layer $i Material Number", currentLineData[i]))
            end
            if n < 0 || n > materials
                throw(PropertyError("Line $(lastLineIndex+1): Material for soil layer $i invalid. Index must be greater than 0 and less than number of materials."))
            end
            soilLayerNumbers[i] = n
        end
        lastLineIndex += 1

        # Read subdivisions
        subdivisions = Array{Int32}(undef, materials)
        currentLineData = []
        try
            currentLineData = parseCurrentLine(input, Int64(materials), lastLineIndex+1, ",")
        catch e
            throw(e)
        end
        for i=1:materials
            n = 0
            try
                n = parse(Int32, currentLineData[i])
            catch e
                throw(IntConvertError(lastLineIndex+1, "Soil Layer $i Subdivisions", currentLineData[i]))
            end
            if n < 2 || n > 50 # TODO: Make MAX_SUBDIVISIONS a constant
                throw(PropertyError("Line $(lastLineIndex+1): Subdivisions for soil layer $i invalid. Value must be greater than 2 and less than 50."))  # TODO: Repalce text "50" with "$(MAX_SUBDIVISIONS)"
            end
            subdivisions[i] = n
        end
        lastLineIndex += 1

        # Initialize All Model Specific Data
        heaveBeginDepth = 0.0
        heaveActiveDepth = 0.0
        swellPressure = Array{Float64}(undef, materials)
        swellIndex = Array{Float64}(undef, materials)
        compressionIndex = Array{Float64}(undef, materials)
        maxPastPressure = Array{Float64}(undef, materials)
        timeAfterConstruction = 0
        elasticModulus = Array{Float64}(undef, materials)
        conePenetration = Array{Float64}(undef, materials)
        # Read Model Specific Data
        if model == 0 # Consolidation Swell
            # Read Heave begin depth, Heave active depth
            currentLineData = []
            try
                currentLineData = parseCurrentLine(input, 2, lastLineIndex+1, ",")
            catch e
                throw(e)
            end
            try
                heaveBeginDepth = parse(Float64, currentLineData[1])
            catch e 
                throw(FloatConvertError(lastLineIndex+1, "heave begin depth", currentLineData[1]))
            end
            if heaveBeginDepth < 0 || heaveBeginDepth > totalDepth 
                throw(PropertyError("Line $(lastLineIndex+1): Heave Begin Depth must be greater than 0 and less than total depth"))
            end
            try
                heaveActiveDepth = parse(Float64, currentLineData[2])
            catch e 
                throw(FloatConvertError(lastLineIndex+1, "heave active depth", currentLineData[2]))
            end
            if heaveActiveDepth < 0 || heaveActiveDepth > totalDepth 
                throw(PropertyError("Line $(lastLineIndex+1): Heave Active Depth must be greater than 0 and less than total depth"))
            end
            lastLineIndex += 1

            # Read swell pressure, swell index, compression index and max past pressure
            for i=1:materials
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 5, lastLineIndex+i, ",")
                catch e
                    throw(e)
                end
                m = 0
                try 
                    m = parse(Int32, currentLineData[1])
                catch e
                    throw(IntConvertError(lastLineIndex+i, "material index $i",currentLineData[1]))
                end
                if m < 1 || m > materials
                    throw(MaterialIndexOutOfBoundsError(lastLineIndex+i, currentLineData[1]))
                end
                sp = 0.0
                try
                    sp = parse(Float64, currentLineData[2])
                catch e 
                    throw(FloatConvertError(lastLineIndex+i, "swell pressure of material $i", currentLineData[2]))
                end
                if sp < 0
                    throw(PropertyError("Line $(lastLineIndex+i): Swell pressure cannot be negative"))
                end
                si = 0.0
                try
                    si = parse(Float64, currentLineData[3])
                catch e 
                    throw(FloatConvertError(lastLineIndex+i, "swell index of material $i", currentLineData[3]))
                end
                if si < 0
                    throw(PropertyError("Line $(lastLineIndex+i): Swell index cannot be negative"))
                end
                ci = 0.0
                try
                    ci = parse(Float64, currentLineData[4])
                catch e 
                    throw(FloatConvertError(lastLineIndex+i, "compression index of material $i", currentLineData[4]))
                end
                if ci < 0
                    throw(PropertyError("Line $(lastLineIndex+i): Compression index cannot be negative"))
                end
                mpp = 0.0
                try
                    mpp = parse(Float64, currentLineData[5])
                catch e 
                    throw(FloatConvertError(lastLineIndex+i, "max past pressure of material $i", currentLineData[5]))
                end
                if mpp < 0
                    throw(PropertyError("Line $(lastLineIndex+i): Max past pressure cannot be negative"))
                end

                swellPressure[m] = sp
                swellIndex[m] = si
                compressionIndex[m] = ci
                maxPastPressure[m] = mpp
            end
            lastLineIndex += materials
        elseif model == 1 # Schmertmann
            # Read Time After Construction
            try
                timeAfterConstruction = parse(Int32, input[lastLineIndex+1])
            catch e 
                throw(IntConvertError(lastLineIndex+1, "time after construction", input[lastLineIndex+1]))
            end
            if timeAfterConstruction < 0
                throw(PropertyError("Line $(lastLineIndex+1): Time After Construction must be greater than 0"))
            end
            lastLineIndex += 1

            # Read cone penetration data
            for i=1:materials
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 2, lastLineIndex+i, ",")
                catch e
                    throw(e)
                end
                m = 0
                try 
                    m = parse(Int32, currentLineData[1])
                catch e
                    throw(IntConvertError(lastLineIndex+i, "material index $i",currentLineData[1]))
                end
                if m < 1 || m > materials
                    throw(MaterialIndexOutOfBoundsError(lastLineIndex+i, currentLineData[1]))
                end
                cp = 0.0
                try
                    cp = parse(Float64, currentLineData[2])
                catch e 
                    throw(FloatConvertError(lastLineIndex+i, "cone penetration of material $i", currentLineData[2]))
                end
                if cp < 0
                    throw(PropertyError("Line $(lastLineIndex+i): Cone penetration resistance cannot be negative"))
                end
                
                # For metric, Cone Penetration is in KPa, convert to Pa
                if units == Int(Metric)
                    cp *= 1000
                end

                conePenetration[m] = cp
            end
            lastLineIndex += materials
        else  # SchmertmannElastic
            # Read Time After Construction
            try
                timeAfterConstruction = parse(Int32, input[lastLineIndex+1])
            catch e 
                throw(IntConvertError(lastLineIndex+1, "time after construction", input[lastLineIndex+1]))
            end
            if timeAfterConstruction < 0
                throw(PropertyError("Line $(lastLineIndex+1): Time After Construction must be greater than 0"))
            end
            lastLineIndex += 1

            # Read elastic modulus data
            for i=1:materials
                currentLineData = []
                try
                    currentLineData = parseCurrentLine(input, 2, lastLineIndex+i, ",")
                catch e
                    throw(e)
                end
                m = 0
                try 
                    m = parse(Int32, currentLineData[1])
                catch e
                    throw(IntConvertError(lastLineIndex+i, "material index $i",currentLineData[1]))
                end
                if m < 1 || m > materials
                    throw(MaterialIndexOutOfBoundsError(lastLineIndex+i, currentLineData[1]))
                end
                em = 0.0
                try
                    em = parse(Float64, currentLineData[2])
                catch e 
                    throw(FloatConvertError(lastLineIndex+i, "elastic modulus of material $i", currentLineData[2]))
                end
                if em < 0
                    throw(PropertyError("Line $(lastLineIndex+i): Elastic modulus cannot be negative"))
                end

                # For metric, Elastic Mod is in KPa, convert to Pa
                if units == Int(Metric)
                    em *= 1000
                end

                elasticModulus[m] = em
            end
            lastLineIndex += materials
        end

        return new(problemName, model, units, foundationType, appliedAt, foundationWidth, foundationLength, appliedPressure, outputIncrements, saturatedAboveWaterTable, materials, materialNames, specificGravity, voidRatio, waterContent, totalDepth, depthGroundWaterTable, foundationDepth, subdivisions, soilLayerNumbers, bounds, heaveBeginDepth, heaveActiveDepth, swellPressure, swellIndex, compressionIndex, maxPastPressure, timeAfterConstruction, elasticModulus, conePenetration)
    end
end

end # module
