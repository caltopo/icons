#!/bin/bash

# Check if ImageMagick (magick) is installed
if ! command -v magick >/dev/null 2>&1; then
    echo "Error: ImageMagick 'magick' command not found. Please install ImageMagick 7+."
    exit 1
fi

# Default settings
overwrite="false"
outdir="resized-png-files"

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --overwrite)
            if [[ "$2" == "true" || "$2" == "false" ]]; then
                overwrite="$2"
                shift 2
            else
                echo "Error: --overwrite must be followed by 'true' or 'false'."
                exit 1
            fi
            ;;
        --help|-h)
            echo "Usage: $0 [--overwrite true|false] file1.png [file2.png ...]"
            echo "  --overwrite true   Overwrite original files (no subdirectory)."
            echo "  --overwrite false  Save resized files in '$outdir/' (default)."
            exit 0
            ;;
        *)
            files+=("$1")
            shift
            ;;
    esac
done

# Exit if no PNG files provided
if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No PNG files specified."
    echo "Usage: $0 [--overwrite true|false] file1.png [file2.png ...]"
    exit 1
fi

# Create output directory if not overwriting
if [ "$overwrite" == "false" ]; then
    mkdir -p "$outdir"
fi

# Process each file
for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")

        if [ "$overwrite" == "true" ]; then
            target="$file"
        else
            target="$outdir/$filename"
        fi

        magick "$file" \
            -resize 24x24 \          # scale to fit within 24x24
            -background none \       # transparent background
            -gravity center \        # center the image
            -extent 24x24 \          # pad to exactly 24x24
            "$target"

        echo "Resized $file -> $target"
    else
        echo "Warning: $file not found, skipping."
    fi
done

echo "All done!"
