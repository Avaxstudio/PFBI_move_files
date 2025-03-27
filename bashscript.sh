#!/bin/bash

# Prompt user for inputs
read -p "Enter the source directory: " source_dir
read -p "Enter the file extension (without dot): " file_ext
read -p "Enter the destination directory: " dest_dir

# Validate source directory
if [ ! -d "$source_dir" ]; then
  echo "Error: Source directory does not exist."
  exit 1
fi

# Validate file extension
if [ -z "$file_ext" ]; then
  echo "Error: No file extension provided."
  exit 1
fi

# Ensure the file extension starts with a dot (e.g., ".txt")
file_ext=".$file_ext"

# Count the number of files to be moved
file_count=$(find "$source_dir" -type f -name "*$file_ext" | wc -l)
  echo "Found '$file_count' files with the extension '$file_ext'."
  
# Create the destination directory if it doesn't exist
mkdir -p "$dest_dir"

# Find files and move them while preserving directory structure
find "$source_dir" -type f -name "*$file_ext" -print0 | while IFS= read -r -d '' file; do
  # Get the relative path of the file
  rel_path="${file#$source_dir/}"
  # Create the same directory structure in the destination directory
  mkdir -p "$dest_dir/$(dirname "$rel_path")"
  # Move the file
  mv "$file" "$dest_dir/$rel_path"
done

echo "All files with extension '$file_ext' have been moved to '$dest_dir', preserving the directory structure."
