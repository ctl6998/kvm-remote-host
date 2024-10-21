#!/bin/bash

# Set the input directory and output file
input_dir="/home/ubuntu/output/output_SparkWC"
output_file="merged_output.txt"

# Check if the input directory exists
if [ ! -d "$input_dir" ]; then
    echo "Input directory does not exist: $input_dir"
    exit 1
fi

# Merge the files
cat "$input_dir"/part-* > "$input_dir/$output_file"

# Check if the merge was successful
if [ $? -eq 0 ]; then
    echo "Files merged successfully into $output_file"
else
    echo "Failed to merge files"
fi


