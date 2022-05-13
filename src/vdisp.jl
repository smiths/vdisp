module vdisp

include("./OutputFormat.jl")
using .OutputFormat

include("./InputParser.jl")
using .InputParser

export lerp, readInputFile

# Path to input_data.dat from runtests.jl
INPUT_DATA_PATH = "../src/.data/input_data.dat"
OUTPUT_DATA_PATH = "../src/.data/output_data.dat"

function readInputFile()
    println("Parsing data...\n")
    inputData = InputData(INPUT_DATA_PATH)
    println("\nParsing done!\n")

    println("Problem: ", inputData.problemName)
    println("Model: ", inputData.model)
    println("Nodal Points: ", inputData.nodalPoints)
    println("Soil Layer Numbers: ", inputData.soilLayerNumber)
    println("Applied Pressure at Points: ", inputData.appliedPressureAtPoints)
    println("Strain at Points: ", inputData.strainAtPoints)

    # Instantiate OutputData object
    outputData = OutputData(INPUT_DATA_PATH)
    
    f = OutputFormat.performGetModelOutput
    g = OutputFormat.getHeader

    OutputFormat.writeOutput([f,f,g,f,g], outputData, OUTPUT_DATA_PATH)
end

readInputFile()

"""
    lerp(a, b, x)

Use linear interpolation to find the y value at x on the line connecting a and b.

# Examples
```julia-repl
julia> lerp((1.0,1.0),(5.0,5.0),3.0)
3.0
```
"""
function lerp(a::Tuple{Float64, Float64}, b::Tuple{Float64, Float64}, x::Float64)
    x1 = a[1]
    y1 = a[2]
    x2 = b[1]
    y2 = b[2]
    if x1 == x2 && y1 == y2
        println("Warning: both points are equal!")
        return y1
    end
    numerator = y1 * (x2-x) + y2 * (x-x1)
    denominator = x2 - x1
    return numerator/denominator
 end

end # module
