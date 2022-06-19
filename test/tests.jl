module Tests

using Test
include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

export consolidationSwellTest, consolidationSwellTest2, schmertTest, schmertElasticTest

function consolidationSwellTest(outputData)
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
    P, PP, heaveAboveFoundationTable, heaveBelowFoundationTable, Δh1, Δh2, Δh = OutputFormat.performGetCalculationValue(outputData)
    # Values calculated in document: https://github.com/smiths/vdisp/files/8871489/Test.Case.Surcharge.Pressure.1.pdf
    @test P[7] == 1.00
    @test P[8] ≈ 0.9985885 rtol=1e-6
    @test P[9] ≈ 0.9189579 rtol=1e-6
    @test P[10] ≈ 0.7964492 rtol=1e-6
    @test P[11] ≈ 0.6825551 rtol=1e-6
    # Values calculated in document: https://github.com/smiths/vdisp/files/8873290/Test.Cases.MECH.pdf
    @test heaveAboveFoundationTable[1,3] ≈ 0.1359761 rtol=1e-6
    @test heaveAboveFoundationTable[1,4] ≈ 1.9900344 rtol=1e-6
    @test heaveAboveFoundationTable[2,3] ≈ 0.1077996 rtol=1e-6
    @test heaveAboveFoundationTable[2,4] ≈ 1.9701033 rtol=1e-6
end

function consolidationSwellTest2(outputData)
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
    # Values calculated in document: https://github.com/smiths/vdisp/files/8845557/Test.case.Calculations.pdf
    @test P[1] == 0.25
    @test P[2] ≈ 0.2543061 rtol=1e-6
    @test P[3] ≈ 0.2586122 rtol=1e-6
    @test P[4] ≈ 0.2629183 rtol=1e-6
    @test P[5] ≈ 0.2672244 rtol=1e-6
    @test PP[1] == 0.0
    @test PP[2] ≈ 0.0199311 rtol=1e-6
    @test PP[3] ≈ 0.0398622 rtol=1e-6
    @test PP[4] ≈ 0.0597933 rtol=1e-6
    @test PP[5] ≈ 0.0797244 rtol=1e-6
end

function schmertTest(outputData)
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
    @test inputData.timeAfterConstruction == 10
    P, PP, settlementTable, Δh = OutputFormat.performGetCalculationValue(outputData)
    # Values calculated in document: 
    @test settlementTable[1,3] ≈ -0.000689697 rtol=1e-6
    @test settlementTable[2,3] ≈ -0.001383052 rtol=1e-6
    @test settlementTable[3,3] ≈ -0.002045984 rtol=1e-6
end

function schmertElasticTest(outputData)
    inputData = outputData.inputData

    @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - SCHMERTMANN"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
    @test inputData.dx == 0.5
    @test string(inputData.model) == string(InputParser.SchmertmannElastic)
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
    @test inputData.elasticModulus[1] == 175.00
    @test inputData.elasticModulus[2] == 250.00
    @test inputData.timeAfterConstruction == 10
    P, PP, settlementTable, Δh = OutputFormat.performGetCalculationValue(outputData)
    # Values calculated in document: 
    @test settlementTable[1,3] ≈ -0.000689697 rtol=1e-6
    @test settlementTable[2,3] ≈ -0.001383052 rtol=1e-6
    @test settlementTable[3,3] ≈ -0.002045984 rtol=1e-6
end

# function testFile2(outputData)
#     inputData = outputData.inputData
# 
#     @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - LEONARD AND FROST"
#     @test inputData.nodalPoints == 17
#     @test inputData.bottomPointIndex == 7
#     @test inputData.soilLayers == 2
#     @test inputData.dx == 0.5
#     @test string(inputData.model) == string(InputParser.LeonardFrost)
#     @test string(inputData.foundation) == string(InputParser.RectangularSlab)
#     @test inputData.soilLayerNumber[1] == 1
#     @test inputData.soilLayerNumber[7] == 1
#     @test inputData.soilLayerNumber[12] == 2
#     @test inputData.soilLayerNumber[14] == 2
#     @test inputData.soilLayerNumber[16] == 2
#     @test inputData.specificGravity[1] == 2.700
#     @test inputData.voidRatio[1] == 1.540
#     @test inputData.waterContent[2] == 19.300
#     @test inputData.depthGroundWaterTable == 8.00
#     @test inputData.equilibriumMoistureProfile == false
#     @test inputData.appliedPressure == 1.00
#     @test inputData.foundationLength == 3.00
#     @test inputData.center == true
#     @test inputData.pressureDilatometerA[1] == 3.00
#     @test inputData.pressureDilatometerB[1] == 15.00
#     @test inputData.conePenetrationResistance[2] == 100.00
# end

# function testFile4(outputData)
#     inputData = outputData.inputData
# 
#     @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - SCHMERTMANN"
#     @test inputData.nodalPoints == 17
#     @test inputData.bottomPointIndex == 7
#     @test inputData.soilLayers == 2
#     @test inputData.dx == 0.5
#     @test string(inputData.model) == string(InputParser.CollapsibleSoil)
#     @test string(inputData.foundation) == string(InputParser.RectangularSlab)
#     @test inputData.soilLayerNumber[1] == 1
#     @test inputData.soilLayerNumber[7] == 1
#     @test inputData.soilLayerNumber[12] == 2
#     @test inputData.soilLayerNumber[14] == 2
#     @test inputData.soilLayerNumber[16] == 2
#     @test inputData.specificGravity[1] == 2.700
#     @test inputData.voidRatio[1] == 1.540
#     @test inputData.waterContent[2] == 19.300
#     @test inputData.depthGroundWaterTable == 8.00
#     @test inputData.equilibriumMoistureProfile == false
#     @test inputData.appliedPressure == 1.00
#     @test inputData.foundationLength == 3.00
#     @test inputData.center == true
#     @test inputData.appliedPressureAtPoints[1,1] == 0.01
#     @test inputData.appliedPressureAtPoints[1,3] == 1.00
#     @test inputData.appliedPressureAtPoints[2,2] == 0.40
#     @test inputData.appliedPressureAtPoints[2,4] == 1.00
#     @test inputData.strainAtPoints[1,1] == 0.00
#     @test inputData.strainAtPoints[1,3] == 2.00
#     @test inputData.strainAtPoints[1,5] == 15.00
#     @test inputData.strainAtPoints[2,2] == 0.80
#     @test inputData.strainAtPoints[2,4] == 8.00
# end


end # module 