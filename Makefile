DOC_DIRS ?= docs/Design/MIS docs/Design/MG docs/Design/SRS Miscellaneous
LATEX_AUX_EXTENSIONS ?= aux fdb_latexmk fls log out synctex.gz toc

all: run

buildDocs:
	julia --project=@. docs/make.jl

precompile:
	rm -f Manifest.toml
	rm -f docs/Manifest.toml
	julia -e "using Pkg; Pkg.activate(\"docs\"); Pkg.instantiate()"
	julia -e "using Pkg; Pkg.activate(\".\"); Pkg.instantiate()"

run:
	julia --project=@. src/vdisp.jl "run"

debug:
	julia --project=@. src/vdisp.jl "debug"

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
