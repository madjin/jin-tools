#!/bin/bash

# set the internal field separator to a newline character to handle spaces in filenames correctly
IFS=$'\n'
# get the current directory
CURRENT_DIR=$(pwd)

# Make sure dependencies are installed
packages=("pandoc" "imagemagick" "wkhtmltopdf")

for package in "${packages[@]}"; do
    if ! dpkg-query -W --showformat='${Status}\n' "$package" | grep -q "install ok installed"; then
        echo "Package '$package' is not installed, installing now..."
        sudo apt-get update && sudo apt-get install -y "$package"
    else
        echo "Package '$package' is already installed."
    fi
done


# loop through the different categories (male, female, shared) of VRM files
# then loop through each category's different traits (e.g. "HATS", "HAIR", "EYEWEAR")
# get the name of the current trait (e.g. "HATS")

for body in "male" "female" "shared"; do
  for trait in $(ls -d "files/$body"/*/); do
    category=$(basename "$trait")
    printf "Processing category %s\n" "$category"

    # Convert README to HTML
    pandoc "$trait"README.md -f gfm+pipe_tables --metadata pagetitle="$category" -t html -s -o "$trait""$category".html --css "../table2.css"

    # Convert HTML to JPEG
    wkhtmltoimage --enable-local-file-access --width 0 "$trait""$category".html "$trait""$category".jpg

    # Measure height to know how much to crop
    height=$(identify -format "%h" "$trait""$category".jpg)
    printf "%s is %d pixels tall\n" "$trait" "$height"

    # Determine crop and tile values based on image height
    if [ "$height" -gt 32000 ]; then
      crop="1x8"
      tile="8x"
    elif [ "$height" -gt 16000 ]; then
      crop="1x6"
      tile="6x"
    elif [ "$height" -gt 9000 ]; then
      crop="1x3"
      tile="3x"
    elif [ "$height" -gt 2048 ]; then
      crop="1x2"
      tile="2x"
    else
      crop="1x1"
      tile="1x"
    fi

    # Convert JPEG to poster image
    convert -density 150 -quality 90 "$trait""$category".jpg -crop "$crop@" +repage +adjoin "$trait"long-site-%03d.jpg
    montage "$trait"long-site-*.jpg -geometry +0+0 -tile $tile -quality 90 "$trait"poster_"$category".jpg
    rm "$trait"long-site*.jpg
    rm "$trait""$category".jpg
    cp "$trait"poster_"$category".jpg img/"$body"/
    done
done
