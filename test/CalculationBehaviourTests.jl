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
    @test toFixed(0.054, 4) == "0.0540"
    @test toFixed(0.0239, 3) == "0.024"
    @test toFixed(0.0, 4) == "0.0000"
end

end # module
