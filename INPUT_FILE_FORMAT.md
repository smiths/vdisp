# Input File Format

The following document will provide users with the specification for the input file format which can be used to quickly fill in the `VDisp` GUI.

## Notation

- `field:Type` means `field` *must* be of type `Type`.

- `field:Type{value1, value2, ...}` means `field` *must* be of type `Type`, and its value must be one of `[value1, value2, ...]`.

- `field:Type[a, b]` means `field` *must* be of type `Type`, and its value must be in range `[a,b]`. Round-brackets, `()`, will be used to indicate the boundary is *exclusive*, while square-brackets, `[]`, will be used to indicate the boundary is *inclusive*

- `field:Type(+)` means `field` *must* be of type `Type`, and its value must be *positive*.

> For more info on Julia types, see our [Getting Started With Julia Guide](https://github.com/smiths/vdisp/wiki/Getting-Started-with-Julia#variables).

## Format

For all `VDisp` input files, the "body" of the input file remains the same and is specified as follows:

```text
Line 1 > title:String
Line 2 > method:Int{0, 1, 2}, unitSystem:Int{0, 1}
Line 3 > foundationType:Int{0, 1}, foundationLength:Float(+), foundationWidth:Float(+)
Line 4 > appliedPressure:Float(+), forcePoint:Int{0, 1} 
Line 5 > outputIncrements:Int{0, 1}, saturationAboveWaterTable:Int{0, 1}
Line 6 > materials:Int(+)
Line 7 (Repeat for each material) > materialIndex:Int[0, materials), materialName:String, specificGravity:Float(+), voidRatio:Float(+), waterContent:Float[0,100] 
Line 8 > totalDepth:Float(+)
Line 9 > depthToFoundation:Float(+), depthToGroundWaterTable:Float(+)
Line 10 > 0, layerBoundary1Depth:Float(+), layerBoundary2Depth:Float(+), ... , totalDepth
Line 11 > materialIndexLayer1:Int[0, materials),  materialIndexLayer2:Int[0, materials), ...
Line 12 > subdivisionsLayer1:Int(+), subdivisionsLayer1:Int(+), ...
```

> Line 10 must have `materials`+2 entries, with the first entry being 0 and the last being `totalDepth`.

> Lines 11 and 12 must have `materials` entries.

Next comes the "method specific" part of the input file. The format depends on the choice for `method` and the options are specified as follows:

### 0 — Consolidation / Swell

```text
Line 13 > heaveBeginDepth:Float[0, heaveActiveDepth), heaveActiveDepth:Float(heaveBeginDepth, totalDepth)
Line 14 (Repeat for each material) > materialIndex:Int[0, materials), swellPressure:Float(+), swellIndex:Float(+), compressionIndex:Float(+), maxPastPressure:Float(+)
```

> `maxPastPressure` is also known as “Preconsolidation Pressure”

### 1 — Schmertmann

```text
Line 13 > yearsAfterConstruction:Int(+)
Line 14 (Repeat for each material) > materialIndex:Int[0, materials), conePenetrationResistance:Float(+)
```

### 2 — Schmertmann Elastic

```text
Line 13 > yearsAfterConstruction:Int(+)
Line 14 (Repeat for each material) > materialIndex:Int[0, materials), elasticModulus:Float(+)
```

## Descriptions

|          **Field**          |                                                  **Description**                                                  | **Units (Metric/Imperial)** |
|:---------------------------:|:-----------------------------------------------------------------------------------------------------------------:|:---------------------------:|
|           `title`           |                                                  Title of Problem                                                 |             N/A             |
|           `method`          |           Calculation Method.<br>0 - Consolidation / Swell<br>1 - Schmertmann<br>2 - Schmertmann Elastic          |             N/A             |
|           `units`           |                                     Unit System.<br>0 - Metric<br>1 - Imperial                                    |             N/A             |
|         `foundation`        |                         Foundation Type.<br>0 - Rectangular Slab<br>1 - Long Strip Footing                        |             N/A             |
|      `foundationLength`     |                                                Length of Foundation                                               |             m/ft            |
|      `foundationWidth`      |                                                Width of Foundation                                                |             m/ft            |
|      `appliedPressure`      |                                           Pressure Applied on Foundation                                          |            Pa/tsf           |
|         `forcePoint`        |                          Point at Which Force is Applied<br>0 - Center<br>1 - Edge/Corner                         |             N/A             |
|      `outputIncrements`     | 0 - Output File Will Show Only Total Settlements<br>1 - Output File Will Show Settlements at Each Depth Increment |             N/A             |
| `saturationAboveWaterTable` |                        0 - Hydrostatic Above Water Table<br>1 - Saturated Above Water Table                       |             N/A             |
|         `materials`         |                                         Number of Materials (Soil Layers)                                         |             N/A             |
|       `materialIndex`       |                                  Unique Index Value Associated With Each Material                                 |             N/A             |
|      `specificGravity`      |                                            Specific Gravity of Material                                           |           unitless          |
|         `voidRatio`         |                                               Void Ratio of Material                                              |           unitless          |
|        `waterContent`       |                                             Water Content of Material                                             |              %              |
|         `totalDepth`        |                                            Total Depth of Soil Profile                                            |             m/ft            |
|     `depthToFoundation`     |                                              Depth to Foundation Base                                             |             m/ft            |
|  `depthToGroundWaterTable`  |                                            Depth to Ground Water Table                                            |             m/ft            |
|    `layerBoundaryiDepth`    |                               Depth of Boundary Between Layer *(i-1)* and Layer *i*                               |             m/ft            |
|     `subdivisionsLayeri`    |                                             Subdivisions of Layer *i*                                             |             N/A             |