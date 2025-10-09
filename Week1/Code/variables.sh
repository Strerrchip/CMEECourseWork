#!/bin/sh
# Desc: illustrate special and assigned variables, user input and command substitution

echo "This script was called with $# parameters"
echo "The script's name is $0"
echo "The arguments are $@"
echo "The first argument is $1"
echo "The second argument is $2"

MY_VAR='some string'
echo "current MY_VAR:" "$MY_VAR"
echo "Please enter a new string"
read MY_VAR
echo "current MY_VAR:" "$MY_VAR"

echo "Enter two numbers separated by space(s)"
read a b
echo "you entered" $a "and" $b "; Their sum is:"
MY_SUM=$(expr $a + $b)
echo $MY_SUM

