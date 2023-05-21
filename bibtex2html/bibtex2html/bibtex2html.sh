#!/bin/bash
BASEDIR=$(dirname "$0")
filename="${1%.*}"
# bibtex2html is from https://www.lri.fr/~filliatr/bibtex2html/
bibtex2html -d -t "${filename}" -m ${BASEDIR}/bibtex.mcr -o ${filename} ${filename}.bib
