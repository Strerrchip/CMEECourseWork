#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Bio-math exercises (power laws, spread, half-life, oscillations, matrices, eigenvalues, linear systems, complex exp).

Run:
  python3 bio_math_exercises.py

Optional:
  python3 bio_math_exercises.py --no-plots
"""

import math
import argparse

#Functions and Graphs Exercise1

import numpy as np

v = 3  # m/day
t = np.array([2,4,8], dtype=float)
r = v*t
A = np.pi*r**2
A

#Functions and Graphs Exercise2

import numpy as np
import matplotlib.pyplot as plt

D = np.linspace(0.5, 5, 200)
T = np.linspace(0.5, 5, 200)

L = D**1.84
S = T**(-0.49)

plt.figure()
plt.plot(D, L)
plt.xlabel("Stem diameter D")
plt.ylabel("Leaf area L (k=1)")
plt.show()

plt.figure()
plt.plot(T, S)
plt.xlabel("Leaf thickness T")
plt.ylabel("Spongy mesophyll fraction S (c=1)")
plt.show()

#Functions and Graphs Exercise3

import numpy as np

N0 = 1e8
h = 6.0
t = np.array([3,6,12], dtype=float)

N = N0*(0.5)**(t/h)
N

#Functions and Graphs Exercise4

import numpy as np
import matplotlib.pyplot as plt

Z0, A, phi = 50, 20, 0
t = np.linspace(0, 24, 1000)  # months
omega = 2*np.pi/12

Z1 = Z0 + A*np.cos(omega*t + phi)
Z2 = Z0 + A*np.cos(2*omega*t + phi)

plt.figure()
plt.plot(t, Z1, label="omega")
plt.plot(t, Z2, label="2*omega")
plt.xlabel("t (months)")
plt.ylabel("Z(t)")
plt.legend()
plt.show()

#Linear Algebra Exercise1

import numpy as np
M = np.array([[0, 3.0],[0.2, 0.8]])
x = np.array([10.0, 5.0])
M @ x

#Linear Algebra Exercise2

import sympy as sp
M = sp.Matrix([[0, 3],[sp.Rational(1,5), sp.Rational(4,5)]])
M.eigenvects()

#Linear Algebra Exercise3

import sympy as sp
A = sp.Matrix([[3,-7],[1,7]])
b = sp.Matrix([4,10])
z = A.LUsolve(b)
A.inv(), z

#Linear Algebra Exercise4

import sympy as sp
t, beta = sp.symbols('t beta', positive=True, real=True)
sp.exp(sp.I*beta*t).expand(complex=True)