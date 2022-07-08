using Test
using vdisp

include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

include("./tests.jl")
using .Tests

# Paths to test input files from runtests.jl
FILE_NAMES = ["consolidationSwellTest", "consolidationSwellTest2", "schmertTest", "schmertElasticTest"]
GUI_FILE_NAMES = ["consolidationSwellGUITest",  "schmertGUITest", "schmertElasticGUITest"]
INPUT_TEST_PATHS = ["../test/testdata/input_$f.dat" for f in FILE_NAMES]
OUTPUT_TEST_PATHS = ["../test/testdata/output_$f.dat" for f in FILE_NAMES]

# Paths to test input files with errors
INPUT_ERROR_PATHS = ["../test/testdata/test_error_$x.dat" for x in 1:2]

# Test GUI Input files
GUI_TEST_FILES = 1
testFunctions = [consolidationSwellGUITest]
for i=1:GUI_FILE_NAMES
    println("\nTesting input file \"input_$(GUI_FILE_NAMES[i]).dat\":")
    @testset "Testing input file \"input_$(GUI_FILE_NAMES[i]).dat\"" begin
        testFunctions[i]("../test/testdata/$(GUI_FILE_NAMES[i]).dat")
    end
end

# Test data input files
TEST_FILES = 4
testFunctions = [consolidationSwellTest, consolidationSwellTest2, schmertTest, schmertElasticTest]
for i=1:TEST_FILES
    println("\nTesting input file \"input_$(FILE_NAMES[i]).dat\":")
    @testset "Test input file \"input_$(FILE_NAMES[i]).dat\"" begin
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
    println("\nTesting error file 1, error expected on line 6:")
    @test_throws Main.OutputFormat.InputParser.ParsingError OutputData(INPUT_ERROR_PATHS[1])
    println("\nTesting error file 2, error expected:")
    @test_throws Main.OutputFormat.InputParser.SoilNumberError OutputData(INPUT_ERROR_PATHS[2])
end
