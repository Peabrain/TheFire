#objects := test1.o blitterhelper.o
#OBJ = $(SRC:.s=.o)

# test.exe: test.c $(objects)
# 	vc +aos68k -O2 -notmpfile -nostdlib -o test.exe $(objects) test.c
programm = test
#OBJ = main.o blitterhelper.o fire.o
#OBJ = main.o blitterhelper.o ham.o mapping.o fire.o wolfenstein.o ptplayer_noa4.s
#OBJ = main.o blitterhelper.o ham.o ptplayer_noa4.s
OBJ = main.o blitterhelper.o ham8.o ptplayer_noa4.s

VC = vc
VASM = vasmm68k_mot
test.exe: $(OBJ) test.c
	$(VC) +kick13 -O2 -notmpfile -nostdlib -o $(programm).exe $(OBJ) test.c
%.o: %.s
	$(VASM) -m68000 -spaces -Fhunk -phxass -x $< -o $@

clean:
	rm *.o
	rm $(programm).exe