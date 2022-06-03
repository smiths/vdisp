module Tests

using Test
include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

export testFile1, testFile2, testFile3, testFile4, testFile5

function testFile1(outputData)
    inputData = outputData.inputData

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

function testFile2(outputData)
    inputData = outputData.inputData

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

function testFile3(outputData)
    inputData = outputData.inputData

    @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - SCHMERTMANN"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
    @test inputData.dx == 0.5
    @test string(inputData.model) == string(InputParser.Schmertmann)
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
    @test inputData.conePenetrationResistance[1] == 70.00
    @test inputData.conePenetrationResistance[2] == 100.00
    @test inputData.conePenetrationResistance[3] == 10.00
end

function testFile4(outputData)
    inputData = outputData.inputData

    @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - SCHMERTMANN"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
    @test inputData.dx == 0.5
    @test string(inputData.model) == string(InputParser.CollapsibleSoil)
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
    @test inputData.appliedPressureAtPoints[1,1] == 0.01
    @test inputData.appliedPressureAtPoints[1,3] == 1.00
    @test inputData.appliedPressureAtPoints[2,2] == 0.40
    @test inputData.appliedPressureAtPoints[2,4] == 1.00
    @test inputData.strainAtPoints[1,1] == 0.00
    @test inputData.strainAtPoints[1,3] == 2.00
    @test inputData.strainAtPoints[1,5] == 15.00
    @test inputData.strainAtPoints[2,2] == 0.80
    @test inputData.strainAtPoints[2,4] == 8.00
end

function testFile5(outputData)
    inputData = outputData.inputData

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
    @test inputData.equilibriumMoistureProfile == true
    @test inputData.appliedPressure == 1.00
    @test inputData.foundationLength == 3.00
    @test inputData.center == true
    @test inputData.swellPressure[1] == 2.00
    @test inputData.swellIndex[2] == 0.10
    @test inputData.compressionIndex[1] == 0.25
    @test inputData.heaveActiveZoneDepth == 8.00
    P, PP, x = OutputFormat.performGetCalculationValue(outputData)
    @test P[1] != PP[1]
    @test P[2] != PP[2]
    @test P[3] != PP[3]
    @test P[4] != PP[4]
end


end # module 