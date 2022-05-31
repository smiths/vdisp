DOC_DIRS ?= docs/Design/MIS docs/Design/MG docs/Design/SRS Miscellaneous
LATEX_AUX_EXTENSIONS ?= aux fdb_latexmk fls log out synctex.gz toc

all: run

run:
	julia --project=@. src/vdisp.jl "./src/.data/input_data.dat" "./src/.data/output_data.dat"

test: FORCE
	cd test && julia --project=@. runtests.jl

FORCE: 

cleanOutput: 
	cd src/.data && rm output*.dat
	cd test/testdata && rm test_output*.dat

cleanDocs: 
	for ext in $(LATEX_AUX_EXTENSIONS) ; do \
		rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.$$ext) ; \
	done 

clean: cleanDocs cleanOutput