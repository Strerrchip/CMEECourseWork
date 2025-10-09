#!/bin/sh
# Author: Leyu Chen leyu.chen25@imperial.ac.uk
# Script: MyExampleScript.sh
# Desc: A simple script to show how variables and $USER work

MSG1="Hello"
MSG2=$USER

echo "$MSG1 $MSG2"
echo "Hello $USER"

