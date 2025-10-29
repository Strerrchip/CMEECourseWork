# Week 2 README

# Summary
- This week focused on learning the fundamentals of Python programming for biological data analysis. I practiced basic syntax, variable assignment, data manipulation, control flow (if, for, while), and writing reusable scripts.  
By the end of the week, I was able to combine all these skills to process real biological text data.

# # Directory structure
- Code
- Data
- Results
- Sandbox
- README

# Monday to do
- # content
  - Understand Python interactive and script modes.
  - Learn how to assign and manipulate variables of different types.
  - Practice type conversion and simple arithmetic operations.
  - Create and run the first Python script.
- # script description
  - # Code/variables.py
    - Demonstrates variable declaration and data types: integers, floats, strings, and booleans.
    - Shows arithmetic operations, type conversion, and string concatenation.
    - The output confirms correct variable handling in Python.
- # The mistake I made
    - Tried to assign variables with invalid syntax (e.g. `5 = a` or `a,b = 5`).
    - Forgot to convert data types before concatenating strings, which caused a `TypeError`.
    - Solved by using `str()` and `int()` for type conversion before combining values.
- # targets
    - Work comfortably in Python script mode.
    - Be able to assign and manipulate variables correctly.
    - Understand basic data types and type conversion in Python.
    - Learn to print output clearly using formatted strings or multiple variables.


# Tuesday to do
- # content
    - Learn how to define and call functions in Python.
    - Understand the use of `if __name__ == '__main__':` for modular code.
    - Practice running and testing scripts from the command line or VS Code terminal.
- # script description
  - # Code/MyExampleScript.py
    - Defines two simple functions: one for greeting and another for addition.
    - Uses a `main()` function as the entry point.
    - Demonstrates the use of the conditional statement `if __name__ == '__main__':` to control when the script runs.
    - Helps understand modular programming structure in Python.
- # targets
    - Be able to create and call functions in Python.
    - Understand and use the `main()` function pattern correctly.
    - Execute Python scripts both in VS Code and in terminal.
    - Learn to test code incrementally.


# Wednesday to do
- Project topic presentation


# Thursday to do

- # Content
    - Learn Python control structures: `if`, `for`, and `while`.
    - Understand logical flow and nested conditions.

- # Script description
    - `Code/loops.py`: Demonstrates the use of `for` and `while` loops.
    - `Code/conditionals.py`: Shows how to use `if`, `elif`, and `else` statements to control program logic.

- # Targets
- Understand and apply basic control structures.
- Practice combining conditions and loops to solve problems.

- # The mistake I made
- Forgot to increment the loop variable in `while`, causing an infinite loop.
- Used `=` instead of `==` in conditional statements.


# Friday to do
- # content
    - Integrate previous skills (variables, loops, and conditionals) into one functional script.
    - Learn how to read from and write to text files.
    - Practice using functions to make scripts modular and reusable.
- # script description
  - # Data/species.txt
    - Example data file containing species names.
    - Used as input for the `oaks.py` script.
  - # Code/oaks.py
    - Defines a function `is_an_oak(name)` that checks whether a given species name starts with "Quercus".
    - Reads species names line by line from the input file (`../Data/species.txt`).
    - Writes all names identified as oaks into a new output file (`../Results/oaks.txt`).
    - Demonstrates file I/O, string handling, loops, and conditional logic in Python.
- # targets
    - Combine file I/O, loops, and functions in a single Python script.
    - Apply filtering and conditional statements to text data.
    - Produce clean, modular, and readable scientific code.
- # the mistake I made
    - Forgot to create the `species.txt` input file, which caused a `FileNotFoundError`.
    - Forgot to close files after writing, so output was not saved.
    - Misspelled the function name or used incorrect indentation in the `if` block.
    - Used `.startswith('Quercus')` without `.lower()`, failing to detect lowercase entries.

# Practicals
  - # variables.py 
    - Demonstrates variable creation, type conversion, and string operations.  
  - # oaks.py 
    - Reads a list of species and filters those belonging to the “Quercus” genus.  
  - # align_seqs.py 
    - Aligns two DNA sequences and outputs the best alignment and score.  
  - # oaks_debugme.py 
    - Debugging version of `oaks.py`, fixed the bug and added error handling.  
  - # cfexercises1.py 
    - Contains several control flow functions and example tests.  
  - # LV1.py 
    - Simulates the classical Lotka–Volterra predator–prey model and outputs plots.  
  - # LV2.py 
    - Modified LV model including carrying capacity (K) and command-line arguments.  
  - # run_LV_models.py 
    - Runs and profiles both LV1 and LV2 scripts for performance comparison.  
