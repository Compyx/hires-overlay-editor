# vim: set noet ts=8 sw=8 sts=8 smartindent:
#
# Makefile for the hires overlay editor


ASM = 64tass
ASM_FLAGS = --ascii --case-sensitive --m6502 --vice-labels --labels $(LABELS) \
	    -Wall -Wshadow -Wstrict-bool -I src


TARGET = hoe.prg

LABELS = labels.txt
SOURCES = src/main.s src/data.s src/status.s src/view.s src/zoom.s src/ui.s


all: $(TARGET)

$(TARGET): $(SOURCES) $(DATA)
	$(ASM) $(ASM_FLAGS) -o $@ $<


.PHONY: clean
clean:
	rm -f $(TARGET)
	rm -f $(LABELS)
