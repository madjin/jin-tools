#!/bin/bash

# set the internal field separator to a newline character to handle spaces in filenames correctly
IFS=$'\n'
# get the current directory
CURRENT_DIR=$(pwd)

# loop through the different categories (male, female, shared) of VRM files
# then loop through each category's different traits (e.g. "HATS", "HAIR", "EYEWEAR")
# get the name of the current trait (e.g. "HATS")
for body in "male" "female" "shared"; do
  for traits in $(ls -d files/"$body"/*/); do  
    category=$(basename "$traits")
    echo $category
    total_folders=0 
    # loop through each folder within the current trait (e.g. "Conductor_Mini_Top_Hat", "Cowboy_Hat")
    for folder in $traits*; do
      # check if the current file is a directory
      # then get the name of the current folder within the current trait (e.g. "Conductor_Mini_Top_Hat")
      if [ -d "$folder" ]; then   
        filename=$(basename "$folder")
        for file in "$folder"/*; do
          # check if the current file is a glb file
          case "$file" in
            *.glb)
              glb_filename=$(basename "$file")
              # check if there is already a corresponding png file for the current glb file
              # also checks if the glb file has been recently updated and needs a new preview
              # if so take a screenshot of the current glb file and save it as a png file
              png_file="$folder/$(basename $glb_filename .glb).png"
              if [ -z "$png_file" ] || [ "$file" -nt "$png_file" ]; then
                if node ./node_modules/.bin/screenshot-glb -i "$folder/$glb_filename" -o "$png_file"; then
                  echo "Screenshot of $glb_filename saved as $(basename $glb_filename .glb).png"
                else
                  echo "Failed to take screenshot of $glb_filename"
                fi
              fi
              ;;
          esac
        done
      fi
    done
    cd "$CURRENT_DIR"
  done
done
