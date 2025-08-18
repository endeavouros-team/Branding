#!/bin/bash
# Lossless PNG optimization script using pngcrush, optipng, and zopflipng
# Creates backups of originals
# optimizes all file in the directory

# Required packages
REQUIRED_PKGS=("pngcrush" "optipng" "zopfli")

# Check for dependencies
missing=()
for pkg in "${REQUIRED_PKGS[@]}"; do
    if ! command -v "$pkg" &>/dev/null; then
        missing+=("$pkg")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "Error: The following required packages are missing: ${missing[*]}"
    echo "On Arch Linux, install them with:"
    echo "  sudo pacman -S ${missing[*]}"
    exit 1
fi

# Create backup folder
mkdir -p backup_pngs

# Process all PNG files in the current directory
for file in *.png; do
    [ -f "$file" ] || continue
    echo "Processing: $file"

    # Backup original
    cp "$file" "backup_pngs/$file"

    # Step 1: pngcrush (brute force + reduce)
    pngcrush -q -brute -reduce "$file" "tmp_$file"
    mv "tmp_$file" "$file"

    # Step 2: optipng (level 7 optimization)
    optipng -o7 -quiet "$file"

    # Step 3: zopflipng (tries all permutations for smallest size)
    zopflipng -m -y "$file" "tmp_$file"
    mv "tmp_$file" "$file"

    echo "Optimized: $file"
done

echo "Done! Originals are in ./backup_pngs/"
