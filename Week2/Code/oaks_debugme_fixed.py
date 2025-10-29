#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: oaks_debugme_fixed.py
# Desc: Find oaks robustly; includes doctests and handles minor typos/punctuation
# Date: Oct 2025

import re
from pathlib import Path
import csv

def _levenshtein_one_or_less(a: str, b: str) -> bool:
    """Return True if edit distance between a and b is <= 1 (insert/delete/substitute).
    This lightweight check is enough for common typos like 'Quercuss' or 'Querucs'.
    """
    if a == b:
        return True
    la, lb = len(a), len(b)
    # length diff > 1 -> distance > 1
    if abs(la - lb) > 1:
        return False
    # same length: allow at most 1 substitution
    if la == lb:
        mism = sum(x != y for x, y in zip(a, b))
        return mism <= 1
    # length differs by 1: allow one insertion/deletion
    if la > lb:
        a, b = b, a  # make a the shorter
        la, lb = lb, la
    i = j = diff = 0
    while i < la and j < lb:
        if a[i] == b[j]:
            i += 1; j += 1
        else:
            diff += 1
            if diff > 1:
                return False
            j += 1  # skip one char in longer string
    # remaining chars in b also count
    diff += (lb - j)
    return diff <= 1

def is_an_oak(name: str) -> bool:
    """
    Return True if a species name belongs to genus Quercus (robust to case, punctuation, minor typos).

    Doctests:
    >>> is_an_oak('Quercus robur')
    True
    >>> is_an_oak('quercus cerris')
    True
    >>> is_an_oak('Fagus sylvatica')
    False
    >>> is_an_oak('Quercuss petraea')   # extra 's' -> treat as oak
    True
    >>> is_an_oak('Querucs suber')      # letters swapped -> treat as oak
    True
    >>> is_an_oak('Quercus. ilex')      # punctuation after genus
    True
    >>> is_an_oak('Quercu robur')       # distance=1 but missing 's' -> treat as oak
    True
    >>> is_an_oak('Que rcus robur')     # weird spacing -> clean then check
    True
    """
    if not name or not name.strip():
        return False
    first = name.strip().split()[0]
    first = re.sub(r'[^A-Za-z]', '', first).lower()  # remove punctuation, to lower
    target = "quercus"
    return _levenshtein_one_or_less(first, target)

def main():
    infile = Path(__file__).resolve().parent.parent / "Data" / "TestOaksData.csv"
    outfile = Path(__file__).resolve().parent.parent / "Results" / "JustOaksData.csv"
    outfile.parent.mkdir(parents=True, exist_ok=True)

    with open(infile, newline='') as f, open(outfile, 'w', newline='') as g:
        rdr = csv.DictReader(f)
        w = csv.writer(g)
        w.writerow(["species"])
        for row in rdr:
            sp = row["species"]
            if is_an_oak(sp):
                w.writerow([sp])

if __name__ == "__main__":
    main()
