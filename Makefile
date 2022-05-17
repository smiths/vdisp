test: FORCE
    # Passing in argument "maketest" lets runtest.jl know to find path to test input relative to directory vdisp/
	julia --project=. test/runtests.jl maketest 

FORCE: 