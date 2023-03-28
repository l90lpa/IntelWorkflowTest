FORT		:= mpiifort -fc=ifx
LLVMLINK	:= llvm-link-15
LLVMOPT		:= opt-15
LLVMDIS		:= llvm-dis-15
#LLVMEnzyme	:= /usr/local/lib/Enzyme/LLVMEnzyme-15.so
LLVMEnzyme	:= /home/lpada/Projects/libs/Enzyme/enzyme/cmake-build-debug/Enzyme/LLVMEnzyme-15.so

FORTFLAGS += -flto
EnzymeNoOpt := -no-vec -unroll=0

app: main.f90
	$(FORT) $(FORTFLAGS) $(EnzymeNoOpt) -O2 -c main.f90
	@echo "\nCompiling done. Now linking, and AD\n"
	$(LLVMDIS) main.o
#	$(LLVMOPT) main.o --load=$(LLVMEnzyme) --enable-new-pm=0 -enzyme -enzyme-globals-default-inactive=1 -o ad.o
#	$(LLVMDIS) ad.o
	$(FORT) $(FORTFLAGS) -O3 main.o -o app

clean:
	rm -f app *.o *.ll *.mod
