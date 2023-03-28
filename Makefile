#FORT		:= mpiifort -fc=ifx
FORT		:= ifx -flto -I/usr/lib/x86_64-linux-gnu/openmpi/lib/../../fortran/gfortran-mod-15/openmpi -I/usr/lib/x86_64-linux-gnu/openmpi/lib -L/usr/lib/x86_64-linux-gnu/openmpi/lib/fortran/gfortran -lmpi_usempif08 -lmpi_usempi_ignore_tkr -lmpi_mpifh -lmpi -lopen-rte -lopen-pal -lhwloc -levent_core -levent_pthreads -lm -lz
LLVMLINK	:= llvm-link-15
LLVMOPT		:= opt-15
LLVMDIS		:= llvm-dis-15
#LLVMEnzyme	:= /usr/local/lib/Enzyme/LLVMEnzyme-15.so
LLVMEnzyme	:= /home/lpada/Projects/libs/Enzyme/enzyme/cmake-build-debug/Enzyme/LLVMEnzyme-15.so

FORTFLAGS :=
#+= -flto
EnzymeNoOpt :=
#:= -no-vec -unroll=0

app: main.f90
	$(FORT) $(FORTFLAGS) $(EnzymeNoOpt) -O2 -c main.f90
	$(LLVMDIS) main.o
	$(LLVMOPT) main.o --load=$(LLVMEnzyme) --enable-new-pm=0 -enzyme -enzyme-globals-default-inactive=1 -o ad.o
	$(LLVMDIS) ad.o
	$(FORT) $(FORTFLAGS) -O3 ad.o -o app

clean:
	rm -f app *.o *.ll *.mod
