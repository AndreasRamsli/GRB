#!/bin/zsh

# Set the source and destination directories
src_dir="/Users/andreas/phys/master/GRB/xspec/GRB211211A/newIntervals"
dest_dir="/Users/andreas/phys/master/GRB/xspec/GRB211211A/properIntervals"

# Set the subdirectories to search and copy
subdirs=("IV" "IV1" "IV2" "V1" "V2")

# Loop over the subdirectories and move the files
for subdir in "${subdirs[@]}"; do
    # Create the source and destination directories for the current subdirectory
    src_subdir="$src_dir/$subdir"
    dest_subdir="$dest_dir/$subdir"

    # Create the destination directory if it doesn't exist
    if [ ! -d "$dest_subdir" ]; then
        mkdir -p "$dest_subdir"
    fi

    # Move the files from the source subdirectory to the destination subdirectory
    mv "$src_subdir/FERMI"* "$dest_subdir"
done

