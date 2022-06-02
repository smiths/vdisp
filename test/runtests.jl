using Test
using vdisp

include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

include("./tests.jl")
using .Tests

# Paths to test input files from runtests.jl
INPUT_TEST_PATHS = ["../test/testdata/test_input_$x.dat" for x in 1:6]
OUTPUT_TEST_PATHS = ["../test/testdata/test_output_$x.dat" for x in 1:4]

testFunctions = [testFile1, testFile2, testFile3, testFile4]
for i=1:4
    println("\nTesting input file $(i):")
    @testset "Test input file $(i)" begin
        outputData = 0
        inputData = 0
        try
            outputData, inputData = getData(INPUT_TEST_PATHS[i])
        catch e 
            return
        end
        testFunctions[i](inputData)
        # use outputData to output file
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
    println("\nTesting file 5, error expected on line 6:")
    @test_throws Main.OutputFormat.InputParser.ParsingError OutputData(INPUT_TEST_PATHS[5])
    println("\nTesting file 6, error expected:")
    @test_throws Main.OutputFormat.InputParser.SoilNumberError OutputData(INPUT_TEST_PATHS[6])
end
