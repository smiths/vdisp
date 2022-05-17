test: FORCE
	cd test
	julia --project="." test/runmaketests.jl

FORCE: 