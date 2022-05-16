module vdisp

include("./OutputFormat.jl")
using .OutputFormat
include("./InputParser.jl")
using .InputParser

export lerp, readInputFile

function readInputFile(inputPath::String, outputPath::String)
    # Instantiate OutputData object
    outputData = OutputData(inputPath)
    
    header = OutputFormat.getHeader
    model = OutputFormat.performGetModelOutput
    foundation = OutputFormat.performGetFoundationOutput
    displacementInfo = OutputFormat.performGetDisplacementOutput

    OutputFormat.writeOutput([header, model, foundation, displacementInfo], outputData, outputPath)
end

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
