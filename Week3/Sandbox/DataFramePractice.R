# create_data_frame.R
names <- c("Alice", "Bob", "Charlie", "Diana")
ages <- c(23, 25, 22, 24)
heights <- c(165, 180, 175, 168)
student <- c(TRUE, TRUE, FALSE, TRUE)

# using data.frame() to create a data frame
people <- data.frame(Name = names, Age = ages, Height = heights, IsStudent = student)

# display the data frame
print(people)
str(people)
summary(people)

# view specific columns
people$Name
people$Age

# access rows
people[2, ]      # second row
people[, 3]      # third column
people[1:3, c("Name", "Height")]  # first three rows of names and heights

# add new column
people$Weight <- c(60, 75, 68, 55)

# remove column
people$IsStudent <- NULL

# view updated data frame
print(people)

write.csv(people, "./Results/people.csv", row.names = FALSE)

# read back from file
read_people <- read.csv("./Results/people.csv")
print(read_people)

