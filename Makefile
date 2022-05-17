test: FORCE
	cd test
	julia --project="." test/runtests.jl

FORCE: 