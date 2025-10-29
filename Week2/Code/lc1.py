#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: lc1.py
# Desc: Demonstrate for-loops and list comprehensions
# Date: Oct 2025

# Traditional loop
x = range(10)
y = []

for i in x:
    if i % 2 == 0:
        y.append(i**2)

print("Using loop:", y)

# List comprehension
y_lc = [i**2 for i in x if i % 2 == 0]
print("Using list comprehension:", y_lc)

