#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: oaks.py
# Desc: Extract all species names that start with 'Quercus' (oaks) from a given file
# Date: Oct 2025

# Function to determine if a name is an oak
def is_an_oak(name):
    """Return True if the species name starts with 'quercus'."""
    return name.lower().startswith('quercus')

# Main function
def main():
    # Input file
    infile = '../Data/species.txt'  # Example data file
    outfile = '../Results/oaks.txt'

    f = open(infile, 'r')
    g = open(outfile, 'w')

    for line in f:
        species = line.strip()
        if is_an_oak(species):
            print(species)
            g.write(species + '\n')

    f.close()
    g.close()

if __name__ == '__main__':
    main()