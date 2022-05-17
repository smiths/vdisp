all: run

run:
	julia --project=@. src/vdisp.jl "./src/.data/input_data.dat" "./src/.data/output_data.dat"

test: FORCE
    # Passing in argument "maketest" lets runtest.jl know to find path to test input relative to directory vdisp/
	julia --project=@. test/runtests.jl maketest 

FORCE: 

cleanOutput: 
	cd src/.data && rm output*.dat

clean: cleanOutput