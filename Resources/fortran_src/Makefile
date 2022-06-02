all: run cleanExec

vdisp: vdisp.for
	gfortran -o $@ $?

build: vdisp

run: vdisp
	chmod u+x $?
	./$?

cleanOutput:
	rm VDOU.DAT

cleanExec:
	rm vdisp

clean: cleanOutput cleanExec
