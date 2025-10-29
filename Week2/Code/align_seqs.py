#!/usr/bin/env python3
# Author: Avery L Chen leyu.chen25@imperial.ac.uk
# Script: align_seqs.py
# Desc: Read two DNA sequences from a file, align the shorter to the longer by sliding,
#       and write the best alignment and score to an output text file.
# Date: Oct 2025

from pathlib import Path
import sys
import csv

def read_two_seqs_from_csv(infile):
    """Read two sequences from a CSV file with 2 rows (or any rows labelled seq1/seq2)."""
    s1, s2 = None, None
    with open(infile, newline="") as f:
        rdr = csv.reader(f)
        for row in rdr:
            if not row:
                continue
            # accept formats: ["seq1","ATCG..."] or ["ATCG...", "..."] etc.
            if len(row) == 2 and row[0].strip().lower().startswith("seq"):
                label, seq = row[0], row[1]
            else:
                # if no labels, take as sequence only
                seq = row[-1]
            seq = "".join(seq.split()).upper()   # remove whitespace, upper-case
            if s1 is None:
                s1 = seq
            elif s2 is None:
                s2 = seq
                break
    if s1 is None or s2 is None:
        raise ValueError("Could not read two sequences from input file.")
    return s1, s2

def calculate_score(longer, shorter, start_pos):
    """Return score for aligning shorter against longer starting at start_pos."""
    score = 0
    for i in range(len(shorter)):
        if start_pos + i >= len(longer):
            break
        if longer[start_pos + i] == shorter[i]:
            score += 1
    return score

def best_alignment(seq_a, seq_b):
    """Return tuple (best_offset, best_score, longer, shorter)."""
    # decide which one is longer
    if len(seq_a) >= len(seq_b):
        longer, shorter = seq_a, seq_b
    else:
        longer, shorter = seq_b, seq_a

    best_score = -1
    best_offset = 0
    # slide shorter along longer
    for start in range(len(longer) - len(shorter) + 1):
        sc = calculate_score(longer, shorter, start)
        if sc > best_score:
            best_score = sc
            best_offset = start
    return best_offset, best_score, longer, shorter

def make_alignment_string(longer, shorter, offset):
    """Return a human-readable alignment string with dots for mismatches."""
    pad = "." * offset
    aligned = pad + shorter
    # pad to the right to match length for printing
    if len(aligned) < len(longer):
        aligned = aligned + "." * (len(longer) - len(aligned))
    return aligned

def write_result(outfile, longer, aligned_shorter, score):
    outdir = Path(outfile).parent
    outdir.mkdir(parents=True, exist_ok=True)
    with open(outfile, "w") as g:
        g.write(f"Best alignment score: {score}\n")
        g.write(f"Longer : {longer}\n")
        g.write(f"Aligned: {aligned_shorter}\n")

def main():
    # default paths
    default_in = Path(__file__).resolve().parent.parent / "Data" / "sequences.csv"
    default_out = Path(__file__).resolve().parent.parent / "Results" / "best_alignment.txt"

    # allow optional CLI args: infile [outfile]
    if len(sys.argv) == 1:
        infile = default_in
        outfile = default_out
    elif len(sys.argv) == 2:
        infile = Path(sys.argv[1])
        outfile = default_out
    else:
        infile = Path(sys.argv[1])
        outfile = Path(sys.argv[2])

    s1, s2 = read_two_seqs_from_csv(infile)
    offset, score, longer, shorter = best_alignment(s1, s2)
    aligned_shorter = make_alignment_string(longer, shorter, offset)
    write_result(outfile, longer, aligned_shorter, score)

    # also show to screen
    print(f"Score: {score}")
    print(f"Longer : {longer}")
    print(f"Aligned: {aligned_shorter}")
    print(f"\nWritten to: {outfile}")

if __name__ == "__main__":
    main()

