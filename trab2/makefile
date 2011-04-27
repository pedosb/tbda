#####
# Autor: Pedro Batista
# Data: 10/04/2011
#####

LATEX = latex -shell-escape
BIBTEX = bibtex
DVIPDF = dvipdf
RM = rm -f

MAIN = relatorio
TARGET = $(MAIN).pdf
DVI = $(MAIN).dvi

SOURCE = relatorio.tex 

all : $(TARGET)

$(TARGET) : $(DVI)
	$(DVIPDF) $(MAIN)

$(DVI) : $(SOURCE)
	$(LATEX) $(MAIN)
	-$(BIBTEX) $(MAIN)
	$(LATEX) $(MAIN)
	$(LATEX) $(MAIN)

clean :
	$(RM) *.aux *.bbl *.blg *.dvi *.log *~ *.pyg

distclean :
	$(RM) $(TARGET)
