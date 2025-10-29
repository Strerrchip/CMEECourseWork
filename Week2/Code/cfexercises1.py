#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: cfexercises1.py
# Desc: Demonstrate control flow and modular programming
# Date: Oct 2025

# Define functions that take arguments and return results

def foo_1(x):
    """Return the square root of x."""
    return x ** 0.5

def foo_2(x, y):
    """Return the larger of x and y."""
    if x > y:
        return x
    else:
        return y

def foo_3(x, y, z):
    """Return the sorted list of x, y, z in ascending order."""
    return sorted([x, y, z])

def foo_4(x):
    """Return x! (factorial of x)."""
    if x == 1:
        return 1
    else:
        return x * foo_4(x - 1)

def foo_5(x):
    """Return the sum of 1 to x."""
    return sum(range(1, x + 1))
def main():
    print("foo_1(9) =", foo_1(9))
    print("foo_2(4,7) =", foo_2(4,7))
    print("foo_3(8,5,6) =", foo_3(8,5,6))
    print("foo_4(5) =", foo_4(5))
    print("foo_5(10) =", foo_5(10))

if __name__ == "__main__":
    main()
