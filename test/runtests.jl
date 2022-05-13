using Test
using vdisp

include("../src/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

# Path to input and output files from runtests.jl
INPUT_DATA_PATH = "../src/.data/input_data.dat"
OUTPUT_DATA_PATH = "../src/.data/output_data.dat"
readInputFile(INPUT_DATA_PATH, OUTPUT_DATA_PATH)

# Path to test input files from runtests.jl
INPUT_TEST_PATH = "../test/.testdata/test_input_1.dat"
OUTPUT_TEST_PATH = "../test/.testdata/test_output_1.dat"

@testset "Test input file 1" begin
    outputData = OutputData(INPUT_TEST_PATH)
    inputData = getfield(outputData, :inputData)
    @test inputData.problemName == "    FOOTING IN EXPANSIVE SOIL"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
    @test inputData.dx == 0.5
    @test string(inputData.model) == string(InputParser.ConsolidationSwell)
    @test string(inputData.foundation) == string(InputParser.RectangularSlab)
end

@testset "Test lerp function" begin
    @test lerp((1.0,1.0),(5.0,5.0),3.0) == 3.0
    @test lerp((1.0,1.0),(5.0,5.0),5.0) == 5.0
    @test lerp((0.0,0.0),(0.0,0.0),0.0) == 0.0
    @test lerp((1.0,2.0),(10.0,20.0),5.0) == 10.0
end