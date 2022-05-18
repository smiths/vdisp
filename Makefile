all: run

run:
	julia --project=@. src/vdisp.jl "./src/.data/input_data.dat" "./src/.data/output_data.dat"

test: FORCE
    # julia --project=@. test/runtests.jl maketest
	cd test && julia --project=@. runtests.jl

FORCE: 

cleanOutput: 
	cd src/.data && rm output*.dat

clean: cleanOutput