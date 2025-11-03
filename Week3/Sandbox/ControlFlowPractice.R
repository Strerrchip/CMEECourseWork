# Sandbox/ControlFlowPractice.R

# This script demonstrates the use of if-else statements in R.
x <- 10

if (x > 0) {
  cat(x, "is positive\n")
} else if (x == 0) {
  cat(x, "is zero\n")
} else {
  cat(x, "is negative\n")
}

# Vectorized ifelse example
values <- c(-2, -1, 0, 1, 2)
result <- ifelse(values > 0, "positive", ifelse(values < 0, "negative", "zero"))
print(result)

# for loop example
for (i in 1:5) {
  cat("Iteration:", i, "\n")
}

# while loop example
count <- 1
while (count <= 5) {
  if (count == 3) {
    cat("Skipping 3\n")
    count <- count + 1
    next
  }
  cat("Count:", count, "\n")
  count <- count + 1
}


#Practical A
numbers <- c(2, 15, 30, 5, 50, 12)

for (n in numbers) {
  if (n < 10) {
    cat(n, "is small\n")
  } else if (n < 25) {
    cat(n, "is medium\n")
  } else {
    cat(n, "is large\n")
  }
}

#Practical B
for (n in numbers) {
  if (n > 40) {
    cat("Reached value > 40, stopping.\n")
    break
  }
  cat("Value:", n, "\n")
}

# apply() example
m <- matrix(1:9, nrow = 3)
print("Matrix m:")
print(m)

row_means <- apply(m, 1, mean)  # 按行求平均
col_sums  <- apply(m, 2, sum)   # 按列求和

cat("Row means:", row_means, "\n")
cat("Column sums:", col_sums, "\n")

sink("./Results/control_flow_output.txt")
cat("Row means:", row_means, "\n")
cat("Column sums:", col_sums, "\n")
sink()
cat(" Results written to ./Results/control_flow_output.txt\n")

