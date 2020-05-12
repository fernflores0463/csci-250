#
# Makefile for CCS Experiment 5 - merge sort
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -m -o $*.out $*.obj > $*.map

#
# Object files
#
OBJECTS = merge_sort.obj merge.obj sort.obj
OBJECTS2 = merge_sort2.obj merge.obj sort.obj

#
# Main target
#
merge_sort.out:	$(OBJECTS)
	$(RLINK) -m -o merge_sort.out $(OBJECTS) > merge_sort.map

merge_sort2.out:	$(OBJECTS2)
	$(RLINK) -m -o merge_sort2.out $(OBJECTS2) > merge_sort2.map
