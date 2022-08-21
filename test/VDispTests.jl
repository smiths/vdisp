"""
This module tests the `pathFromVar()` function of the 
`vdisp.jl` module.
"""
module VDispTests

using Test
include("../src/vdisp.jl")
using .vdisp

export testPathFromVar

function testPathFromVar()
    @test vdisp.pathFromVar("file:///Users/user/Desktop") == "/Users/user/Desktop"
    @test vdisp.pathFromVar("file://C://Users/user/Desktop") == "C://Users/user/Desktop"
    @test vdisp.pathFromVar("") == ""
    @test vdisp.pathFromVar("abc") == "abc"
end

end # module