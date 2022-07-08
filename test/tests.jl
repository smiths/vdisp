module Tests

using Test
include("../src/OutputFormat/OutputFormat.jl")
using .OutputFormat

include("../src/InputParser.jl")
using .InputParser

export consolidationSwellTest, consolidationSwellTest2, schmertTest, schmertElasticTest, consolidationSwellGUITest, schmertGUITest, schmertElasticGUITest

function consolidationSwellTest(outputData)
    inputData = outputData.inputData

    @test inputData.problemName == "    FOOTING IN EXPANSIVE SOIL"
    @test inputData.nodalPoints == 17
    @test inputData.bottomPointIndex == 7
    @test inputData.soilLayers == 2
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

function consolidationSwellGUITest(filePath::String)
    guiData = GUIData(filePath)

    @test guiData.problemName == "Problem 1 - Consolidation/Swell"
    @test guiData.model == 0
    @test guiData.units == 1
    @test guiData.foundation == 0
    @test guiData.foundationWidth == 3.00
    @test guiData.appliedPressure == 1.00
    @test guiData.appliedAt == 0
    @test guiData.outputIncrements == 1
    @test guiData.saturatedAboveWaterTable == 1

    @test guiData.materials == 2
    @test guiData.materialNames[1] == "Sand"
    @test guiData.specificGravity[1] == 2.6
    @test guiData.waterContent[1] == 20.0
    @test guiData.materialNames[2] == "Dirt"
    @test guiData.specificGravity[2] == 2.3
    @test guiData.voidRatio[2] == 1.35

    @test guiData.totalDepth == 16.0
    @test guiData.foundationDepth == 7.5
    @test guiData.depthGroundWaterTable == 15.0
    @test guiData.bounds[1] == 0.0
    @test guiData.bounds[2] == 12.0
    @test guiData.bounds[3] == 16.0
    @test guiData.subdivisions[1] == 12
    @test guiData.subdivisions[2] == 4

    @test guiData.heaveBeginDepth == 0.0
    @test guiData.heaveActiveDepth == 8.0
    @test guiData.swellPressure[1] == 2.0
    @test guiData.swellIndex[1] == 0.1
    @test guiData.compressionIndex[1] == 0.3
    @test guiData.maxPastPressure[1] == 2.0
    @test guiData.swellPressure[2] == 3.0
    @test guiData.swellIndex[2] == 0.15
    @test guiData.compressionIndex[2] == 0.35
    @test guiData.maxPastPressure[2] == 3.0
end

function schmertGUITest(filePath::String)
    guiData = GUIData(filePath)

    @test guiData.problemName == "Problem 2 - Schmertmann"
    @test guiData.model == 1
    @test guiData.units == 1
    @test guiData.foundation == 1
    @test guiData.foundationWidth == 5.50
    @test guiData.appliedPressure == 1.50
    @test guiData.appliedAt == 0
    @test guiData.outputIncrements == 1
    @test guiData.saturatedAboveWaterTable == 0

    @test guiData.materials == 3
    @test guiData.materialNames[1] == "Sand"
    @test guiData.specificGravity[1] == 2.6
    @test guiData.waterContent[1] == 20.0
    @test guiData.materialNames[2] == "Dirt"
    @test guiData.specificGravity[2] == 2.3
    @test guiData.voidRatio[2] == 1.35
    @test guiData.materialNames[3] == "Clay"
    @test guiData.specificGravity[3] == 3.567


    @test guiData.totalDepth == 16.0
    @test guiData.foundationDepth == 7.5
    @test guiData.depthGroundWaterTable == 16.0
    @test guiData.bounds[1] == 0.0
    @test guiData.bounds[2] == 5.0
    @test guiData.bounds[3] == 12.0
    @test guiData.bounds[4] == 16.0
    @test guiData.soilLayerNumbers[1] == 1
    @test guiData.soilLayerNumbers[2] == 3
    @test guiData.soilLayerNumbers[3] == 2
    @test guiData.subdivisions[1] == 10
    @test guiData.subdivisions[2] == 7
    @test guiData.subdivisions[3] == 2

    @test guiData.timeAfterConstruction == 35
    @test guiData.conePenetration[1] == 70.0
    @test guiData.conePenetration[2] == 140.0
    @test guiData.conePenetration[3] == 240.0
end

function schmertElasticGUITest(filePath::String)
    guiData = GUIData(filePath)

    @test guiData.problemName == "Problem 3 - Schmertmann Elastic"
    @test guiData.model == 2
    @test guiData.units == 0
    @test guiData.foundation == 1
    @test guiData.foundationWidth == 5.50
    @test guiData.appliedPressure == 1.50
    @test guiData.appliedAt == 0
    @test guiData.outputIncrements == 1
    @test guiData.saturatedAboveWaterTable == 0

    @test guiData.materials == 3
    @test guiData.materialNames[1] == "Sand"
    @test guiData.specificGravity[1] == 2.6
    @test guiData.waterContent[1] == 20.0
    @test guiData.materialNames[2] == "Dirt"
    @test guiData.specificGravity[2] == 2.3
    @test guiData.voidRatio[2] == 1.35
    @test guiData.materialNames[3] == "Clay"
    @test guiData.specificGravity[3] == 3.567


    @test guiData.totalDepth == 16.0
    @test guiData.foundationDepth == 7.5
    @test guiData.depthGroundWaterTable == 16.0
    @test guiData.bounds[1] == 0.0
    @test guiData.bounds[2] == 5.0
    @test guiData.bounds[3] == 12.0
    @test guiData.bounds[4] == 16.0
    @test guiData.soilLayerNumbers[1] == 1
    @test guiData.soilLayerNumbers[2] == 3
    @test guiData.soilLayerNumbers[3] == 2
    @test guiData.subdivisions[1] == 20
    @test guiData.subdivisions[2] == 7
    @test guiData.subdivisions[3] == 2

    @test guiData.timeAfterConstruction == 1
    @test guiData.elasticModulus[1] == 34
    @test guiData.elasticModulus[2] == 75.5
    @test guiData.elasticModulus[3] == 112.4
end

# Testing files for old models (LeonardFrost and CollapsibleSoil)
# function testFile2(outputData)
#     inputData = outputData.inputData
# 
#     @test inputData.problemName == "    FOOTING IN GRANULAR SOIL - LEONARD AND FROST"
#     @test inputData.nodalPoints == 17
#     @test inputData.bottomPointIndex == 7
#     @test inputData.soilLayers == 2
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