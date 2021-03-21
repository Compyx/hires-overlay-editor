# vim: set noet ts=8 sw=8 sts=8 smartindent:
#
# Makefile for the hires overlay editor

# Assembler binary
ASM = 64tass
# Assembler flags
ASM_FLAGS = --ascii --case-sensitive --m6502 --vice-labels --labels $(LABELS) \
	    -Wall -Wshadow -Wstrict-bool -I src \
	    -DDEBUG=true


# Target, raw .prg
TARGET = hoe.prg

 # VICE labels file
LABELS = labels.txt

# Source files
SOURCES = src/main.s \
	  src/data.s src/status.s src/view.s src/zoom.s src/ui.s src/uidata.s
# External data files
DATA = data/font5.prg


all: $(TARGET)

$(TARGET): $(SOURCES) $(DATA)
	$(ASM) $(ASM_FLAGS) -o $@ $<


.PHONY: clean
clean:
	rm -f $(TARGET)
	rm -f $(LABELS)
