# Sandbox/VectorMatrixPractice.R

# create two numeric vectors
x <- c(1, 2, 3, 4, 5)
y <- c(10, 20, 30, 40, 50)

# print the vectors
print(x)
print(y)

# Vector Operations 
sum_xy <- x + y
diff_xy <- y - x
prod_xy <- x * y
ratio_xy <- y / x

cat("Sum: ", sum_xy, "\n")
cat("Difference: ", diff_xy, "\n")
cat("Product: ", prod_xy, "\n")
cat("Ratio: ", ratio_xy, "\n")

# Vector Indexing
cat("First element of x:", x[1], "\n")
cat("Last element of y:", y[length(y)], "\n")

# Matrix Creation
m <- matrix(1:9, nrow = 3, ncol = 3)
print("Matrix m:")
print(m)

# Matrix Operations
cat("Element (2,3):", m[2, 3], "\n")
cat("Second row:", m[2, ], "\n")
cat("Third column:", m[, 3], "\n")

# Transpose the matrix
m_T <- t(m)
print("Transposed matrix:")
print(m_T)

# Matrix Addition, Subtraction, and Multiplication
A <- matrix(1:4, 2, 2)
B <- matrix(c(2, 0, 1, 3), 2, 2)

# Matrix operations
A_plus_B <- A + B
A_minus_B <- A - B
A_mult_B <- A %*% B  

cat("A + B:\n"); print(A_plus_B)
cat("A - B:\n"); print(A_minus_B)
cat("A %*% B:\n"); print(A_mult_B)

# Inverse
A_inv <- solve(A)
cat("Inverse of A:\n")
print(A_inv)

# Check if A * A_inv is the identity matrix
I <- A %*% A_inv
cat("A * A_inv =\n")
print(I)

# Practical Application
set.seed(123)  # Ensure reproducibility
R <- matrix(runif(9, 1, 10), nrow = 3)
print("Random Matrix R:")
print(R)

det_R <- det(R)
inv_R <- solve(R)
eig_R <- eigen(R)

cat("Determinant of R:", det_R, "\n")
cat("Inverse of R:\n")
print(inv_R)
cat("Eigenvalues of R:\n")
print(eig_R$values)

write.csv(R, "./Results/RandomMatrix.csv", row.names = FALSE)
cat("RandomMatrix.csv saved to ./Results/\n")
