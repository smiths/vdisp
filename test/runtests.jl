using Test
using vdisp

@test lerp((1.0,1.0),(5.0,5.0),3.0) == 3.0
@test lerp((1.0,1.0),(5.0,5.0),5.0) == 5.0
@test lerp((0.0,0.0),(0.0,0.0),0.0) == 0.0
@test lerp((1.0,2.0),(10.0,20.0),5.0) == 10.0