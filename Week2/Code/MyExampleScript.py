#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: MyExampleScript.py
# Desc: Demonstrate function definition and main program structure
# Date: Oct 2025

# Define a function to print a greeting
def greet(name):
    """Print a simple greeting message."""
    print("Hello,", name, "! Welcome to Python scripting.")

# Define another function to do a simple calculation
def add_two_numbers(x, y):
    """Return the sum of two numbers."""
    return x + y

# The main program
def main():
    print("This is the main part of the script.")
    greet("Leyu")
    result = add_two_numbers(5, 7)
    print("The sum of 5 and 7 is:", result)

# Run main() only if executed directly
if __name__ == "__main__":
    main()
