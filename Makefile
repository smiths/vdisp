all: run

run:
	julia --project=@. src/vdisp.jl "./src/.data/input_data.dat" "./src/.data/output_data.dat"

test: FORCE
    # julia --project=@. test/runtests.jl maketest
	cd test && julia --project=@. runtests.jl

FORCE: 

cleanOutput: 
	cd src/.data && rm output*.dat

cleanMIS:
	cd docs/Design/MIS && rm -f *.aux *.fdb_latexmk *.fls *.log *.out *.synctex.gz *.toc

cleanMG:
	cd docs/Design/MG && rm -f *.aux *.fdb_latexmk *.fls *.log *.out *.synctex.gz *.toc

cleanMisc:
	cd Miscellaneous && rm -f *.aux *.fdb_latexmk *.fls *.log *.out *.synctex.gz *.toc

cleanDocs: cleanMisc cleanMG cleanMIS

clean: cleanOutput cleanDocs