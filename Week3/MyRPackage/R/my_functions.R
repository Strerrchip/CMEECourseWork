#' Calculate factorial of a number
#' @param n Non-negative integer
#' @return Factorial of n
#' @export
MyFactorial <- function(n) {
  if (n < 0) stop("n must be non-negative")
  if (n == 0) return(1)
  Reduce(`*`, 1:n)
}

#' Convert Celsius to Fahrenheit
#' @param c Temperature in Celsius
#' @return Temperature in Fahrenheit
#' @export
CtoF <- function(c) (9/5) * c + 32
