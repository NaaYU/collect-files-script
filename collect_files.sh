#!/usr/bin/env bash
set -euo pipefail

max_depth=""
if [[ "${1-}" == "--max_depth" ]]; then
  max_depth="$2"
  shift 2
fi

if [[ $# -ne 2 ]]; then
  echo "Usage: $0 [--max_depth N] INPUT_DIR OUTPUT_DIR"
  exit 1
fi

input_dir="$1"
output_dir="$2"

if [[ ! -d "$input_dir" ]]; then
  echo "Error: input directory '$input_dir' not found."
  exit 1
fi

mkdir -p "$output_dir"

find "$input_dir" -type f -print0 | while IFS= read -r -d '' file; do
  rel="${file#"$input_dir"/}"
  depth=$(grep -o "/" <<< "$rel" | wc -l)

  # если нет max_depth ИЛИ глубина больше max_depth — кладём в корень
  if [[ -z "$max_depth" ]] || [[ "$depth" -gt "$max_depth" ]]; then
    target="$output_dir"
  else
    target="$output_dir/$(dirname "$rel")"
    mkdir -p "$target"
  fi

  name="$(basename "$file")"
  base="${name%.*}"
  ext="${name##*.}"
  dest="$target/$name"
  cnt=1
  while [[ -e "$dest" ]]; do
    dest="$target/${base}_${cnt}.${ext}"
    ((cnt++))
  done

  cp "$file" "$dest"
done