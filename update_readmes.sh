#!/bin/bash

IFS=$'\n'
CURRENT_DIR=$(pwd)

for body in "male" "female" "shared"; do
  for traits in $(ls -d files/"$body"/*/); do
    category=$(basename "$traits")
      echo $category
      echo "# $category" > "$category.md"
      echo "" >> "$category.md"
      echo "| Folder Name | Opensea | Reference | Layer | GLB File | Preview |" >> "$category.md"
      echo "| ----------- | ------- | --------- | ------| -------- | ------- |" >> "$category.md"
      total_folders=0 
      for folder in $traits*; do
        if [ -d "$folder" ]; then
          jpg_file=""
	  jpg_filename=""
          png_file=""
	  layer=""
          glb_file=""
          glb_filename=""
	  filename="[$(basename "$folder")](https://m3org.com/"$body"/$(basename "$folder"))"
	  for file in "$folder"/*; do
	    category_encoded=$(echo "$category" | sed 's/_/%20/g')
	    folder_encoded=$(echo "$filename" | sed 's/_/%20/g')
	    opensea_link="<a href='https://opensea.io/collection/danknugz?search[stringTraits][0][name]="$category_encoded"&search[stringTraits][0][values][0]="$folder_encoded"' target='_blank'>Opensea</a>"
            case "$file" in
              *.png)
                png_filename=$(basename "$file")
                preview="<a href='$(basename "$folder")/$(basename $(realpath --relative-to="$PWD" "$file"))' target='_blank'><img src='$(basename "$folder")/$(basename $(realpath --relative-to="$PWD" "$file"))' height='128'></a>"
		if [[ $png_filename == "layer_"* ]]; then
                  layer="<a href='$(basename "$folder")/$(basename $(realpath --relative-to="$PWD" "$file"))' target='_blank'><img src='$(basename "$folder")/small-$(basename $(realpath --relative-to="$PWD" "$file"))' height='128'></a>"
		fi
                ;;
              *.jpg)
		jpg_filename="$(basename "$file")"
		if [[ $jpg_filename == "thumb_"* ]]; then
                  jpg_file="<a href='$(basename "$folder")/ref_$(echo "$jpg_filename" | sed 's/^thumb_//')' target='_blank'><img src='$(basename "$folder")/$(basename $(realpath --relative-to="$PWD" "$file"))' height='128'></a>"
    fi 
                ;;
              *.glb)
                glb_filename=$(basename "$file")
		glb_file="<a href='$(basename "$folder")/$glb_filename?raw=true' target='_blank'>Download :heavy_check_mark:</a>"
                ;;
            esac
          done
          if [[ "$png_filename" != "${glb_filename%.*}.png" ]]; then
            preview=""
          fi

          echo "| $filename | $opensea_link | $jpg_file | $layer | $glb_file | $preview |" >> "$category.md"
	  total_folders=$((total_folders+1))
  
          if [[ $glb_file == ":heavy_check_mark:" ]]; then
            folders_with_glb=$((folders_with_glb+1))
          else
            folders_without_glb+=("$folder")
          fi
        fi
      done

      echo "" >> "$category.md"
      echo "" >> "$category.md"
      echo "moving $category.md to $category/README.md"
      mv "$category.md" "files/$body/$category/README.md"
      done
    cd "$CURRENT_DIR"
  done
