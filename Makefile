# Building documentation automatically with Roxygen2
# (thanks to Karl Broman for this trick!)
doc:
	R -e 'devtools::document()'
	
all: doc
.PHONY: doc

