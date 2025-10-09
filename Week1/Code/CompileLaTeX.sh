#!/bin/bash
# Author: Leyu Chen
# Script: CompileLaTeX.sh
# Description: Compile a LaTeX document (with BibTeX) and clean auxiliary files

if [ $# -eq 0 ]; then
    echo "Usage: bash CompileLaTeX.sh <filename without .tex>"
    exit 1
fi

filename="${1%.tex}"

pdflatex "$filename.tex"
bibtex "$filename"
pdflatex "$filename.tex"
pdflatex "$filename.tex"

# Open PDF
evince "$filename.pdf" &

# Clear files
rm -f *.aux *.log *.bbl *.blg
