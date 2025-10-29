#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: lc2.py
# Desc: Demonstrate nested loops and comprehensions
# Date: Oct 2025

# Nested loop
pairs = []
for i in range(3):
    for j in range(3):
        pairs.append((i, j))

print("Nested loops:", pairs)

# Equivalent list comprehension
pairs_lc = [(i, j) for i in range(3) for j in range(3)]
print("List comprehension:", pairs_lc)
