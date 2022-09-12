# Output File Format

The following document will provide users with the specification for the format of the output files produced by `VDisp` calculations.

## Effective Stress Files

`VDisp` automatically produces two output files when the user downloads their output. One file contains all the calculation info, while another file (of the same name) contains info about the effective stresses of each soil sublayer. Both files have the same name, but this file has the `.eff.dat` file extension.

This file contains a table of the following format:

| Soil Layer | Effective Stress of Soil (tsf) | Effective Stress After Placing Load (tsf) |
|:----------:|:------------------------------:|:-----------------------------------------:|
|      x     |                x               |                     x                     |
|      x     |                x               |                     x                     |

## Format

This section outlines the format of the main output file produced by `VDisp`.

### Repeat of Input

Every file contains a repeat of the input given for traceability purposes. This “metadata” section has the following format:

```text
Line 1 > Title:String
Line 2 > Table of increment depths for each soil layer
Line 3 > Model
Line 4 > Foundation Type
Line 5 > Depth of Foundation
Line 6 > Total Depth of Soil Profile
Line 7 > Material type and name for each soil sublayer
Line 8 > Material properties
Line 9 > Depth to Ground Water Table
Line 10 > Output Increments or Total Displacement Only
Line 11 > Equilibrium Saturated or Hydrostatic Above Water Table
Line 12 > Force Applied At (Center / Edge or Corner)
```

## Output

Next comes the “method specific” part of the output file. The format depends on the choice for `method` and the options are specified as follows:

### 1 - Consolidation / Swell

```text
Line 13 > Material Properties Continued (swell pressure, swell index, compression index, max past pressure)
Line 14 > Heave distribution above foundation table (shows depth, heave contribution and excess pore pressure for each soil sublayer above the foundation)
Line 15 > Heave distribution below foundation table (shows depth, heave contribution and excess pore pressure for each soil sublayer below the foundation)
Line 16 > Heave contribution above foundation
Line 17 > Heave contribution below foundation
Line 18 > Total heave contribution
```

### 2 - Schmertmann

```text
Line 13 > Time after construction
Line 14 > Settlement below foundation (shows depth and settlement of each soil sublayer below the foundation)
Line 15 > Total settlement below foundation
```

### 3 - Schmertmann Elastic

```text
Line 13 > Time after construction
Line 14 > Settlement below foundation (shows depth and settlement of each soil sublayer below the foundation)
Line 15 > Total settlement below foundation
```
