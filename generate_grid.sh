#!/bin/bash

category=$(echo $(basename $PWD))

for body in "male" "female" "shared"; do
  for traits in $(ls -d files/"$body"/*/); do
    category=$(basename "$traits")
    echo "Generating HTML for $body $category"

    echo '<!DOCTYPE html>' >> index.html
    echo '<html>' >> index.html
    echo '<head>' >> index.html
    echo "<title>$body $category</title>" >> index.html
    echo '<style>' >> index.html
    echo '.gallery {display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 12px; padding: 12px;}' >> index.html
    echo '.gallery img {border: 6px solid red; max-width: 100%; height: auto;}' >> index.html
    echo '.gallery a {text-align: center; display: block;}' >> index.html
    echo '.gallery .glb img {border: 6px solid green;}' >> index.html
    echo 'h1 {text-align: center;}' >> index.html
    echo '</style>' >> index.html
    echo '</head>' >> index.html
    echo '<body>' >> index.html
    echo "<h1>$body $category</h1>" >> index.html
    echo '<div class="gallery">' >> index.html
    while read line; do
      folder_name=$(echo $line | awk -F '/' '{print $4}' | sed 's/_/ /g')
      #filegator="https://files.m3org.com/#/?cd=/$body/"
      url="https://m3org.com/files"
      folder=$(echo $line | awk -F '/' '{print $4}')
      if ls files/$body/$category/$folder/*.glb 1> /dev/null 2>&1; then
        echo "<a href=\"$filegator$category/$folder\"><div class=\"glb\"><img src=\"$url/$line\" /><br>$folder_name</div></a>" >> index.html
      else
        echo "<a href=\"$filegator$category/$folder\"><div><img src=\"$url/$line\" /><br>$folder_name</div></a>" >> index.html
      fi
    done < <(find ./files/$body/$category/ -type f -name 'thumb_*' | sed 's|./||')
    echo '</div>' >> index.html
    echo '</body>'>> index.html
    echo '</html>'>> index.html

    echo "moving index.html to files/$body/$category/index.html"
    mv index.html "files/$body/$category/index.html" 
    done
done
