outer_function <- function(a) middle_function(a)
middle_function <- function(b) inner_function(b)
inner_function <- function(c) { result <- c / d; return(result) }  # d is undefined
outer_function(1)
traceback()
