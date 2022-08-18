# vdisp.jl

`VDisp` is a one-dimensional soil settlement analysis software created to aid undergraduate civil engineering students in their studies of geotechnical engineering. It is created using the `Julia` programming language, and `Qt/QML` markup language for the front-end GUI.

## Calculations

`VDisp` calculations are handled by the `CalculationBehaviour.jl` module. The following functions are responsible for calculating the *effective stresses* of the soil before placing any load, the *effective stresses* **after** placing the load, and any method specific calculations required afterwards.

```@docs
CalculationBehaviour.getEffectiveStress
CalculationBehaviour.getSurchargePressure
CalculationBehaviour.getValue
CalculationBehaviour.schmertmannApproximation
```

## Input Files

`VDisp` input files are parsed using the `InputParser.jl` module. This module is responsible for parsing input files, creating `InputData` instances, and reporting any possible errors in the input file format in a descriptive and helpful manner.

> Note: `VDisp` still contains code that parses the old input file format from the original `VDispl` project. This code is kept in mainly for testing purposes, in which we test the new `VDisp`'s results against that of the original program's. This also allows flexibility for any future developers or contributors to the project!

```@docs
InputParser.parseCurrentLine
InputParser.InputData
InputParser.GUIData
vdisp.createOutputDataFromGUI
vdisp.writeGUIDataToFile
```

### Error Handling

As mentioned above, the `InputParser.jl` module is also responsible for handling any errors that might come up in input files. The following
are custom defined exceptions to help in this process.

```@docs
InputParser.ParsingError
InputParser.FoundationError
InputParser.SoilNumberError
InputParser.NotEnoughValuesError
InputParser.ModelError
InputParser.UnitError
InputParser.FoundationTypeError
InputParser.FloatConvertError
InputParser.IntConvertError
InputParser.BoolConvertError
InputParser.DimensionNegativeError
InputParser.MaterialIndexOutOfBoundsError
InputParser.PropertyError
```

## Old Functions

The `VDisp` program has kept in some of the old functionality of `VDispl`, like parsing the old input file format and directly writing to an output file. The functions assisting with this process are still available for any future contributors or curious developers to play around with and are listed below:

```@docs
vdisp.readInputFile
```

Documentation for vdisp.jl
