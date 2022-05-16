using Test
using vdisp

include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

# Path to input and output files from runtests.jl
INPUT_DATA_PATH = "../src/.data/input_data.dat"
OUTPUT_DATA_PATH = "../src/.data/output_data.dat"
readInputFile(INPUT_DATA_PATH, OUTPUT_DATA_PATH)

# Paths to test input files from runtests.jl
INPUT_TEST_PATHS = ["../test/.testdata/test_input_$x.dat" for x in 1:4]
OUTPUT_TEST_PATHS = ["../test/.testdata/test_output_$x.dat" for x in 1:4]

println("Testing input file 1:")
@testset "Test input file 1" begin
    outputData = OutputData(INPUT_TEST_PATHS[1])
    inputData = getfield(outputData, :inputData)
    @test inputData.problemName == "    FOOTING IN EXPANSIVE SOIL"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
    @test inputData.dx == 0.5
    @test string(inputData.model) == string(InputParser.ConsolidationSwell)
    @test string(inputData.foundation) == string(InputParser.RectangularSlab)
    @test inputData.soilLayerNumber[1] == 1
    @test inputData.soilLayerNumber[7] == 1
    @test inputData.soilLayerNumber[12] == 2
    @test inputData.soilLayerNumber[14] == 2
    @test inputData.soilLayerNumber[16] == 2
    @test inputData.specificGravity[1] == 2.700
    @test inputData.voidRatio[1] == 1.540
    @test inputData.waterContent[2] == 19.300
    @test inputData.depthGroundWaterTable == 8.00
    @test inputData.equilibriumMoistureProfile == false
    @test inputData.appliedPressure == 1.00
    @test inputData.foundationLength == 3.00
    @test inputData.center == true
    @test inputData.swellPressure[1] == 2.00
    @test inputData.swellIndex[2] == 0.10
    @test inputData.compressionIndex[1] == 0.25
    @test inputData.heaveActiveZoneDepth == 8.00
end

println("Testing input file 2:")
@testset "Test input file 2" begin
    outputData = OutputData(INPUT_TEST_PATHS[2])
    inputData = getfield(outputData, :inputData)
    @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - LEONARD AND FROST"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
    @test inputData.dx == 0.5
    @test string(inputData.model) == string(InputParser.LeonardFrost)
    @test string(inputData.foundation) == string(InputParser.RectangularSlab)
    @test inputData.soilLayerNumber[1] == 1
    @test inputData.soilLayerNumber[7] == 1
    @test inputData.soilLayerNumber[12] == 2
    @test inputData.soilLayerNumber[14] == 2
    @test inputData.soilLayerNumber[16] == 2
    @test inputData.specificGravity[1] == 2.700
    @test inputData.voidRatio[1] == 1.540
    @test inputData.waterContent[2] == 19.300
    @test inputData.depthGroundWaterTable == 8.00
    @test inputData.equilibriumMoistureProfile == false
    @test inputData.appliedPressure == 1.00
    @test inputData.foundationLength == 3.00
    @test inputData.center == true
    @test inputData.pressureDilatometerA[1] == 3.00
    @test inputData.pressureDilatometerB[1] == 15.00
    @test inputData.conePenetrationResistance[2] == 100.00
end