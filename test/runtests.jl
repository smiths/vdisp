using Test
using vdisp

include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

include("./tests.jl")
using .Tests

TEST_FILES = 6

# Paths to test input files from runtests.jl
INPUT_TEST_PATHS = ["../test/testdata/test_input_$x.dat" for x in 1:TEST_FILES]
OUTPUT_TEST_PATHS = ["../test/testdata/test_output_$x.dat" for x in 1:TEST_FILES]

# Paths to test input files with errors
INPUT_ERROR_PATHS = ["../test/testdata/test_error_$x.dat" for x in 1:2]

testFunctions = [testFile1, testFile2, testFile3, testFile4, testFile5, testFile6]
for i=1:TEST_FILES
    println("\nTesting input file $(i):")
    @testset "Test input file $(i)" begin
        outputData = 0
        inputData = 0
        try
            outputData, inputData = getData(INPUT_TEST_PATHS[i])
        catch e 
            return
        end
        testFunctions[i](outputData)
        # use outputData to output file
        OutputFormat.writeDefaultOutput(outputData, OUTPUT_TEST_PATHS[i])
    end
end

@testset "Testing Error Files" begin
    # @test_throws ParsingError OutputData(INPUT_TEST_PATHS[5])
    # I wish the above code would work, however it appears 
    # that by "exporting" ParsingError in InputParser Julia 
    # makes a COPY of this error in this class at runtime, thus 
    # the two error objects are not actually "equal" 
    # Output in console:
    #       Expected: ParsingError
    #       Thrown: Main.OutputFormat.InputParser.ParsingError
    # Thus, I copied the exact type from above to the line below
    println("\nTesting error file 1, error expected on line 6:")
    @test_throws Main.OutputFormat.InputParser.ParsingError OutputData(INPUT_ERROR_PATHS[1])
    println("\nTesting error file 2, error expected:")
    @test_throws Main.OutputFormat.InputParser.SoilNumberError OutputData(INPUT_ERROR_PATHS[2])
end
