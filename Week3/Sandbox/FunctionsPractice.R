# Sandbox/FunctionsPractice.R
# Control Flow and Functions Practice 

# if / else
x <- 5
if (x > 10) {
  cat("x is greater than 10\n")
} else if (x == 10) {
  cat("x equals 10\n")
} else {
  cat("x is less than 10\n")
}

# for loop
for (i in 1:5) {
  cat("Iteration:", i, "\n")
}

# while loop
count <- 1
while (count <= 3) {
  cat("Count:", count, "\n")
  count <- count + 1
}

# Define a simple function
Square <- function(x) {
  return(x^2)
}

# Use the function
nums <- c(1, 2, 3, 4)
squared <- Square(nums)
cat("Squares of 1–4:", squared, "\n")

# Function with condition
CheckEvenOdd <- function(n) {
  if (n %% 2 == 0) {
    return(paste(n, "is even"))
  } else {
    return(paste(n, "is odd"))
  }
}

cat(CheckEvenOdd(5), "\n")
cat(CheckEvenOdd(10), "\n")
