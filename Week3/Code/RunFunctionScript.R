# Code/RunFunctionScript.R
# Run and test MyFunctionScript.R 

setwd("~/Documents/CMEECourseWork/Week3")

# use source to run the function script
source("Code/MyFunctionScript.R")

# Test functions
cat("5! =", MyFactorial(5), "\n")
cat("20°C =", CtoF(20), "°F\n")

nums <- c(2, 3, 4, 9, 13)
for (n in nums) {
  cat(n, "is prime?", IsPrime(n), "\n")
}
