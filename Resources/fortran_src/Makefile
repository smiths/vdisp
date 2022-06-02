all: run cleanExec

vdisp: vdisp.for
	gfortran -o $@ $?

build: vdisp

run: vdisp
	chmod u+x $?
	./$?

cleanOutput:
	rm -f VDOU.DAT

cleanExec:
	rm -f vdisp

clean: cleanOutput cleanExec
