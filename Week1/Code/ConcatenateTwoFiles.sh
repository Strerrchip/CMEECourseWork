#!/bin/bash
# Author: Leyu Chen
# Script: ConcatenateTwoFiles.sh
# Desc: Concatenate the contents of two files into a new one
# Args: 1 -> first file
#       2 -> second file
#       3 -> output file

# 检查参数数量
if [ $# -ne 3 ]; then
  echo "Usage: bash ConcatenateTwoFiles.sh <file1> <file2> <output>"
  exit 1
fi

# 检查输入文件是否存在
if [ ! -f "$1" ]; then
  echo "Error: file not found: $1"
  exit 1
fi

if [ ! -f "$2" ]; then
  echo "Error: file not found: $2"
  exit 1
fi

# 合并文件
cat "$1" > "$3"
cat "$2" >> "$3"

echo "Merged File is $3"
echo
cat "$3"
