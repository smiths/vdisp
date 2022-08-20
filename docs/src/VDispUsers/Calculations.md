# Calculations

`VDisp` calculations are handled by the `CalculationBehaviour.jl` module. The following functions are responsible for calculating the *effective stresses* of the soil before placing any load, the *effective stresses* **after** placing the load, and any method specific calculations required afterwards.

```@docs
CalculationBehaviour.getEffectiveStress
CalculationBehaviour.getSurchargePressure
CalculationBehaviour.getValue
CalculationBehaviour.schmertmannApproximation
```
