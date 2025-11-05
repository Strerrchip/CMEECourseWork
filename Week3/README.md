# Week 3 – R Programming Practice

## Summary
This week I learned how to use R in a more advanced way.  
I practiced reading and writing data files, plotting graphs, writing functions, running automated scripts, and even creating a simple R package.  
Although it was sometimes difficult, it helped me understand how R works in real data analysis.

---

## Directory Structure
- Code
- Data
- Results
- Sandbox
- MyRPackage
- README


---

## Content
This week's tasks focused on the following areas:

1. **Data Input and Output**  
   Learned how to read and write data files in R using `read.csv()`, `write.csv()`, and `write.table()`.

2. **Data Visualization**  
   Created scatter plots, histograms, and boxplots to show data patterns.

3. **Function Writing**  
   Practiced defining custom functions and testing them.

4. **Automation**  
   Used loops and scripts to automatically process and analyze multiple datasets.

5. **R Package Creation**  
   Created a small R package that contains my own functions (`MyFactorial`, `CtoF`).

---

## Script Description

| Script | Description |
|---------|-------------|
| **DataIOPractical.R** | Reads and writes data files (CSV and TXT) to test R’s data input and output functions. |
| **DataPlotPractical.R** | Produces several plots (scatter plot, boxplot, histogram) and saves them into a PDF file. |
| **MyFunctionScript.R** | Defines self-written functions such as factorial and Celsius-to-Fahrenheit conversion. |
| **RunFunctionScript.R** | Loads and tests the functions from MyFunctionScript.R. |
| **FunctionsPractice.R** | Practice file for loops, if-statements, and simple function logic. |
| **LoopAutomationPractice.R** | Demonstrates how to automate repeated data operations using for-loops. |
| **AutomateDataProcessing.R** | Runs several R scripts automatically and saves their results into the Results folder. |
| **test.R** | Tests data types and conversions (integer, numeric, character, logical, Roman). |
| **MyRPackage/R/my_functions.R** | Contains the main functions used in my personal R package. |

---

## Mistakes I Made and What I Learned

1. **Wrong file paths**  
   At first, I used `./Data/trees.csv` in the wrong working directory, which caused “file not found” errors.  
   I learned to always check the working directory with `getwd()` and use relative paths correctly.

2. **Git push rejected (non-fast-forward)**  
   I could not push to GitHub because my local branch was behind the remote one.  
   I learned to run `git pull --rebase origin main` before pushing again.

3. **Package installation failed**  
   The `devtools` package failed to install because of missing dependencies.  
   I learned to install required system packages first and then re-install in R.

4. **Plotting errors**  
   The column names in my CSV file did not match the script.  
   I fixed the problem by checking the data frame with `colnames(trees)`.

5. **Wrong function usage**  
   I wrote `create("MyRPackage")` instead of `usethis::create_package("MyRPackage")`.  
   I learned that R functions often belong to specific packages and must be called correctly.

---

## Target
My goal this week was to become more comfortable using R for data analysis and to understand the full workflow from data import, processing, visualization, automation, to package creation.  
I also aimed to improve my ability to manage R projects using GitHub and VS Code.  
After completing this week’s exercises, I feel more confident in writing and organizing R scripts for future projects.

---


