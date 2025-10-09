#!/bin/bash
# Author: Leyu Chen
# Script: CountLines.sh
# Desc: Count the number of lines in a given file
# Args: 1 -> file name

# Check if argument is provided
if [ $# -ne 1 ]; then
  echo "Usage: bash CountLines.sh <file>"
  exit 1
fi

# Check if the file exists
if [ ! -f "$1" ]; then
  echo "Error: file not found: $1"
  exit 1
fi

# Count lines
NumLines=$(wc -l < "$1")
echo "The file $1 has $NumLines lines"
echo
