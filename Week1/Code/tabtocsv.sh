#!/bin/sh
# Author: Leyu Chen
# Script: tabtocsv.sh
# Desc: Replace tabs with commas; save as <input>.csv
# Args: 1 -> tab-delimited file

if [ $# -ne 1 ]; then
  echo "Usage: bash tabtocsv.sh <tab_file>"
  exit 1
fi

infile="$1"
if [ ! -f "$infile" ]; then
  echo "Error: file not found: $infile"
  exit 1
fi

outfile="${infile}.csv"
echo "Creating a comma delimited version of $infile ..."
tr -s "\t" "," < "$infile" > "$outfile"
echo "Done! Saved to $outfile"
