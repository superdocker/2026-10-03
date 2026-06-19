#!/bin/bash
cd "$(dirname "$0")"

files=()
while IFS= read -r -d '' f; do
  files+=("$(basename "$f")")
done < <(find gallery -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) -print0 | sort -z)

json="["
for i in "${!files[@]}"; do
  [ $i -gt 0 ] && json+=","
  json+="\"${files[$i]}\""
done
json+="]"

echo "$json" > gallery/images.json
echo "Update complete: ${#files[@]}장 (gallery/images.json)"
