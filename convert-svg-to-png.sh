#!/bin/bash

# --- SVG to PNG Converter Script ---
# This script finds all .svg files in a specified directory and its subdirectories,
# converts them to 24x24 pixel .png files using rsvg-convert,
# and places the resulting .png files in the same directory as the original .svg files.

# Check if rsvg-convert is installed
if ! command -v rsvg-convert &> /dev/null
then
    echo "Error: rsvg-convert is not installed or not in your PATH."
    echo "Please install it. On Debian/Ubuntu: sudo apt-get install librsvg2-bin"
    echo "On macOS with Homebrew: brew install librsvg"
    exit 1
fi

# Check if a directory path is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <directory_path>"
    echo "Example: $0 ./my_icons"
    echo "This will convert all .svg files found in ./my_icons and its subdirectories."
    exit 1
fi

# Store the provided directory path
TARGET_DIRECTORY="$1"

# Check if the provided path is a valid directory
if [ ! -d "$TARGET_DIRECTORY" ]; then
    echo "Error: The provided path '$TARGET_DIRECTORY' is not a valid directory."
    exit 1
fi

echo "Starting SVG to PNG conversion in '$TARGET_DIRECTORY'..."
echo "Output PNGs will be 24x24 pixels and saved next to their original SVG files."
echo "-------------------------------------------------------------------------"

# Find all .svg files recursively within the target directory
# -type f: Only consider regular files
# -name "*.svg": Match files ending with .svg
# -print0: Print file names null-delimited, which is safer for filenames with spaces or special characters
find "$TARGET_DIRECTORY" -type f -name "*.svg" -print0 | \
while IFS= read -r -d $'\0' svg_file; do
    # Get the directory of the current SVG file
    svg_dir=$(dirname "$svg_file")
    # Get the base name of the SVG file (e.g., "icon.svg")
    svg_basename=$(basename "$svg_file")
    # Get the name without extension (e.g., "icon")
    file_name_no_ext="${svg_basename%.svg}"

    # Construct the full path for the output PNG file
    png_output_file="${svg_dir}/${file_name_no_ext}.png"

    echo "Converting: '$svg_file' -> '$png_output_file'"

    # Perform the conversion using rsvg-convert
    # -w 24: Sets the output width to 24 pixels
    # -h 24: Sets the output height to 24 pixels
    # -o: Specifies the output file
    if rsvg-convert -w 24 -h 24 -o "$png_output_file" "$svg_file"; then
        echo "  Successfully converted."
    else
        echo "  Failed to convert '$svg_file'."
    fi
done

echo "-------------------------------------------------------------------------"
echo "Conversion process completed."
