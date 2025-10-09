# Week 1 README

# Directory structure
- Code
- Data
- Results
- Sandbox
- README

# Monday to do
- Induction and History


# Tuesday to do
- # content
  - Learn basic command line tools (ls, cd, cat, grep, find, wc, tail)
  - Understand file paths, redirection, pipes, and wildcards
- # script description
  - # Code/UnixPrac1.txt
    - This script contains a series of UNIX commands practiced in this Section.  
    - It includes:
      - Counting lines in files using `wc -l`
      - Printing specific lines using `tail`
      - Counting characters with `wc -m`
      - Finding patterns such as “ATGC” with `grep`
      -  Calculating AT/GC ratios using `grep`, `sort`, and `uniq`
    - Each command demonstrates an important UNIX skill,such as using pipes (`|`) to combine commands and redirection (`>`, `>>`) to save outputs.
  - # Data/spawannxs.txt
    - A text data file downloaded from the course GitHub.repository.  
    - Used to practice text searching commands like `grep`.
  - # Sandbox/
    - This folder contains test files I created while practicing commands (e.g., `test.txt`, `File1.txt`).  
    - They are not part of the final analysis but help to understand how commands work.
- # Targets
  - Work with files and folders using command line
  - Search and count text with UNIX tools  
  - Get comfortable with Linux/UNIX environment 


# Wednesday to do
- # content
  - Learn how to write and execute shell scripts.
  - Understand how to define variables, use loops and    conditions, and handle files.
  - Practice automating tasks using Bash scripts.
- # Script description
  - # Code/MyExampleScript.sh
    - The first example script that prints simple text messages to the terminal.
    - Demonstrates how to define and use variables in Bash.
    - Shows how text can include variables (e.g., `$USER`) and how `echo` works.
  - # Code/tabtocsv.sh
    - Converts a tab-delimited text file to a comma-separated CSV file.
    - Takes one argument: the input tab file. 
    - Checks if the file exists before running. 
    - The output file is saved as `<input>.csv` in the same directory.  
    - Uses `tr` to replace tabs (`\t`) with commas (`,`).
  - # Code/CountLines.sh
    - Counts how many lines are in a given text file.
    - Takes one argument: the input file.
    - Uses `wc -l` to calculate the number of lines and displays the result clearly. 
    - Helps understand the basics of command-line file handling.
  - # Code/ConcatenateTwoFiles.sh
    - Merges two input files into a single output file.
    - Ensures both files exist before running. 
    - Writes the merged result to `Results/Merged.txt`.
    - Demonstrates how to handle multiple file inputs and redirection.
  - # Code/tiff2png.sh
    - Converts `.tif` image files into `.png` format using ImageMagick. 
    - Checks whether ImageMagick is installed before running.
    - Searches the current directory for `.tif` files and converts all of them.  
    - The converted `.png` files are saved in the same directory. 
    - Useful for learning automation of image conversion tasks.
  - # Code/csvtospace.sh
    - Converts a CSV file (comma-separated) to a space-separated text file.  
    - Avoids overwriting the original CSV file by saving as `<input>_space.txt`.  
    - Handles missing values by replacing empty cells with `NA`.  
    - Includes error handling for missing or invalid input files.  
    - Strengthens understanding of `awk` usage and file safety checks.
- # The mistake I made
  - The `tiff2png.sh` script initially failed because the test `.tif` files were empty placeholders, not real image files.  
  → The issue was fixed by creating valid `.tif` images or using downloaded samples.  
  - The `tabtocsv.sh` script was not executable at first because file permission was missing.  
  → Fixed by using `chmod +x tabtocsv.sh`.  
  - The `CountLines.sh` test file contained only two lines, leading to confusion about `wc -l` counting logic.  
  → Realized that `wc -l` counts newline characters, not text rows.  
  - The `csvtospace.sh` script was missing in the directory at first.  
  → Solved by manually creating it in the correct folder (`Week1/Code/`).  
  - Path confusion occurred several times (working inside `Sandbox` vs `Code`).  
  → Learned to use `pwd` and relative paths (`../`) to ensure correct execution.  
- # target
  - Develop ability to automate simple file operations using shell scripts.  
  - Learn to handle text and data files efficiently with Bash tools.  
  - Gain confidence in writing structured, reusable scripts for future analysis.
  



