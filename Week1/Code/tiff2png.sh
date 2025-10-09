#!/bin/bash
# Author: Leyu Chen
# Script: tiff2png.sh
# Desc: Convert all .tif images in the current directory to .png format
# Date: Oct 2025

# 检查是否安装了 convert 命令
if ! command -v convert &> /dev/null
then
    echo "Error: ImageMagick not installed. Please run: sudo apt install imagemagick"
    exit 1
fi

# 检查是否存在 .tif 文件
shopt -s nullglob
files=(*.tif)
if [ ${#files[@]} -eq 0 ]; then
    echo "No .tif files found in the current directory."
    exit 0
fi

# 转换所有 .tif 文件
for f in *.tif; do
    echo "Converting $f ..."
    convert "$f" "$(basename "$f" .tif).png"
done

echo "All conversions done!"
