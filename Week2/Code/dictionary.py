#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: dictionary.py
# Desc: Demonstrate dictionary creation and iteration
# Date: Oct 2025

# Create a dictionary
fruits = {"apple": 2, "banana": 3, "orange": 1}

# Iterate keys and values
for fruit, count in fruits.items():
    print(f"{fruit}: {count}")

# Dictionary comprehension
squared = {k: v**2 for k, v in fruits.items()}
print("Squared counts:", squared)
