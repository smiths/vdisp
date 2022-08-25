# Output

As mentioned in the `VDisp Users > Output` page, `VDisp` has a default output format. However, some users may want a different output format. This can easily be achieved through the `writeOutput` function of the `OutputFormat.jl` module.

```@docs
OutputFormat.writeOutput
```

## Output Functions

The following functions can be used by the `writeOutput` function to write to an output file. They are used in `VDisp` in a predefined order, but can be manipulated to fit other needs.

```@docs
OutputFormat.getHeader
OutputFormat.getHeaderValues
OutputFormat.getFoundationDepth
OutputFormat.getFoundationDepthValues
OutputFormat.getSoilTable
OutputFormat.getSoilTableValues
OutputFormat.getMaterialInfoTable
OutputFormat.getMaterialInfoTableValues
OutputFormat.getDepthToGroundWaterTable
OutputFormat.getDepthToGroundWaterTableValue
OutputFormat.performGetModelOutput
OutputFormat.performGetModelValue
OutputFormat.performGetFoundationOutput
OutputFormat.performGetFoundationValue
OutputFormat.performGetDisplacementOutput
OutputFormat.performGetDisplacementValue
OutputFormat.performGetEquilibriumOutput
OutputFormat.performGetEquilibriumValue
OutputFormat.performGetForcePointOutput
OutputFormat.performGetForcePointValue
OutputFormat.performGetCalculationOutput
OutputFormat.performGetCalculationValue
```

## Specific Behaviour Functions

The following functions are used to get specific instances of the "changing behaviour" modules of `VDisp`.

```@docs
OutputFormat.getModelOutBehaviour
OutputFormat.getFoundationOutBehaviour
OutputFormat.getDisplacementInfoBehaviour
OutputFormat.getEquilibriumInfoBehaviour
OutputFormat.getForcePointOutputBehaviour
OutputFormat.getCalculationOutputBehaviour
```
