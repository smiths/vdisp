module vdisp
export lerp

function lerp(a::Tuple{Float64,Float64}, b::Tuple{Float64,Float64}, x::Float64)
    x1 = a[1]
    y1 = a[2]
    x2 = b[1]
    y2 = b[2]
    if x1 == x2 && y1 == y2
        println("Warning: both points are equal!")
        return y1
    end
    numerator = y1 * (x2 - x) + y2 * (x - x1)
    denominator = x2 - x1
    return numerator / denominator
end

end # module
