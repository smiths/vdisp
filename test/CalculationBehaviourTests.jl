"""
This module tests the `toFixed()` function of the 
`CalculationBehaviour.jl` module.
"""
module CalculationBehaviourTests

using Test

include("../src/OutputFormat/CalculationBehaviour.jl")
using .CalculationBehaviour

export testToFixed

function testToFixed()
    @test toFixed(0.054, 3) == "0.054"
    @test toFixed(-0.054, 3) == "-0.054"
    @test toFixed(0.054, 4) == "0.0540"
    @test toFixed(0.0239, 3) == "0.024"
    @test toFixed(0.0, 4) == "0.0000"
    @test toFixed(1.05999999, 5) == "1.06000"
    @test toFixed(1.05319999, 5) == "1.05320"
    @test toFixed(0.000000314159, 5) == "3.14159e-7"
    @test toFixed(-0.000000314159, 5) == "-3.14159e-7"
    @test toFixed(0.00000031, 5) == "3.10000e-7"
    @test toFixed(1200000.0000031, 5) == "1.20000e+6"
    @test toFixed(-1200000.0000031, 5) == "-1.20000e+6"
    @test toFixed(-1255990.0000031, 5) == "-1.25599e+6"
end

end # module
