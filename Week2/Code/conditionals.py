#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: conditionals.py
# Desc: Demonstrate conditional statements in Python
# Date: Oct 2025

x = 10
y = 20

if x < y:
    print("x is less than y")
elif x == y:
    print("x is equal to y")
else:
    print("x is greater than y")

# Nested conditions
if x > 5:
    if y > 15:
        print("Both x and y are large numbers")
