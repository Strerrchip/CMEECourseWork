#!/bin/bash
# Author: Leyu Chen
# Script: csvtospace.sh
# Description: Convert CSV (comma separated) to space-separated text file
# Usage: bash csvtospace.sh <input.csv>

if [ $# -ne 1 ]; then
    echo "Usage: bash csvtospace.sh <input.csv>"
    exit 1
fi

infile="$1"

if [ ! -f "$infile" ]; then
    echo "Error: file '$infile' not found!"
    exit 1
fi

outfile="${infile%.csv}_space.txt"

if [ -f "$outfile" ]; then
    echo "Error: output file '$outfile' already exists. Aborted."
    exit 1
fi

awk 'BEGIN{FS=","; OFS=" "} {for(i=1; i<=NF; i++) if ($i=="") $i="NA"; print $0}' "$infile" > "$outfile"

echo "Conversion done! Saved as '$outfile'."
