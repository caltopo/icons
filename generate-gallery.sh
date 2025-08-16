#!/bin/bash

# Default values
OUTPUT="index.html"
ROOT="."
GITHUB_URL="http://github.com/caltopo/icons"
BRANCH="main"
LABELS="no"      # default changed to no
COLUMNS=4        # default columns for directories

# Function to display help
show_help() {
    echo "Usage: $0 [--github URL] [--branch BRANCH] [--output FILE] [--root DIR] [--labels yes|no] [--columns 1-4] [--help]"
    echo ""
    echo "Generate an HTML gallery of all PNG icons in subdirectories (recursively) with GitHub links."
    echo ""
    echo "Options:"
    echo "  --github URL            Base GitHub URL of the repo (default: $GITHUB_URL)"
    echo "  --branch BRANCH         Branch name (default: main)"
    echo "  --output FILE, -o FILE  Output HTML file (default: index.html)"
    echo "  --root DIR, -r DIR      Root directory to scan (default: current directory)"
    echo "  --labels yes|no         Show image labels (default: no)"
    echo "  --columns N             Number of directory columns in grid (1-6, default: 4)"
    echo "  --help                  Display this help message"
}

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --github) GITHUB_URL="$2"; shift ;;
        --branch) BRANCH="$2"; shift ;;
        --output|-o) OUTPUT="$2"; shift ;;
        --root|-r) ROOT="$2"; shift ;;
        --labels) LABELS="$2"; shift ;;
        --columns) COLUMNS="$2"; shift ;;
        --help) show_help; exit 0 ;;
        *) echo "Unknown parameter: $1"; show_help; exit 1 ;;
    esac
    shift
done

# Validate labels option
if [[ "$LABELS" != "yes" && "$LABELS" != "no" ]]; then
    echo "Error: --labels must be 'yes' or 'no'"
    exit 1
fi

# Validate columns
if ! [[ "$COLUMNS" =~ ^[1-6]$ ]]; then
    echo "Error: --columns must be 1 through 6"
    exit 1
fi

# Start HTML
cat <<EOF > "$OUTPUT"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Icon Gallery</title>
<style>
body { font-family: Arial, sans-serif; padding: 20px; }
h2 { margin-top: 0; margin-bottom: 10px; font-size: 16px; }

.dir-grid {
    display: grid;
    grid-template-columns: repeat($COLUMNS, 1fr);
    gap: 20px;
}

.directory {
    border: 1px solid #ddd;
    padding: 10px;
}

.icon-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 4px;
}

a { text-decoration: none; color: inherit; }
.icon-item img { display: block; max-width: 100%; }
EOF

if [ "$LABELS" = "yes" ]; then
    cat <<'EOF' >> "$OUTPUT"
.icon-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    width: 100px;
}
.icon-item div {
    margin-top: 5px;
    font-size: 12px;
    text-align: center;
}
EOF
else
    cat <<'EOF' >> "$OUTPUT"
.icon-item { display: inline-block; }
EOF
fi

cat <<'EOF' >> "$OUTPUT"
</style>
</head>
<body>
<h1>Icon Gallery</h1>
<div class="dir-grid">
EOF

# Crawl directories recursively
find "$ROOT" -type d | sort | while read -r dir; do
    png_files=("$dir"/*.png)
    if [ -e "${png_files[0]}" ]; then
        folder_name=$(realpath --relative-to="$ROOT" "$dir")
        folder_url="$GITHUB_URL/tree/$BRANCH/$folder_name"
        echo "<div class='directory'>" >> "$OUTPUT"
        echo "<h2><a href='$folder_url'>$folder_name</a></h2>" >> "$OUTPUT"
        echo "<div class='icon-grid'>" >> "$OUTPUT"

        for file in "${png_files[@]}"; do
            [ -f "$file" ] || continue
            file_name=$(basename "$file")
            file_rel=$(realpath --relative-to="$ROOT" "$file")
            # Updated raw GitHub URL for image
            file_url="$GITHUB_URL/blob/$BRANCH/$file_rel"
            file_src="https://raw.githubusercontent.com/caltopo/icons/$BRANCH/$file_rel"

            if [ "$LABELS" = "yes" ]; then
                echo "<div class='icon-item'><a href='$file_url'><img src='$file_src' alt='$file_name' title='$file_name'><div>$file_name</div></a></div>" >> "$OUTPUT"
            else
                echo "<div class='icon-item'><a href='$file_url'><img src='$file_src' alt='$file_name' title='$file_name'></a></div>" >> "$OUTPUT"
            fi
        done

        echo "</div></div>" >> "$OUTPUT"
    fi
done

# End HTML
echo "</div></body></html>" >> "$OUTPUT"

echo "Generated $OUTPUT successfully."

