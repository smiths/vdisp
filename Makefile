DOC_DIRS ?= docs/Design/MIS docs/Design/MG docs/Design/SRS Miscellaneous

all: run

run:
	julia --project=@. src/vdisp.jl "./src/.data/input_data.dat" "./src/.data/output_data.dat"

test: FORCE
    # julia --project=@. test/runtests.jl maketest
	cd test && julia --project=@. runtests.jl

FORCE: 

cleanOutput: 
	cd src/.data && rm -f output*.dat

cleanDocs: 
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.aux)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.fdb_latexmk)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.fls)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.log)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.out)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.out)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.synctex.gz)
	rm -f $(foreach dir, $(DOC_DIRS), $(dir)/*.toc)

clean: cleanDocs cleanOutput