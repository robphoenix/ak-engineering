#!/usr/bin/env bash
# Writes resized WebP variants (name-<width>.webp) next to each source image in images/.
# Re-run after replacing a source photo. Needs macOS sips and cwebp (brew install webp).
set -eu
cd "$(dirname "$0")/../images"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

resize() {
  src="$1"; shift
  base="${src%.*}"
  for w in "$@"; do
    sips -s format jpeg -s formatOptions 95 --resampleWidth "$w" "$src" --out "$tmp/$base-$w.jpg" >/dev/null
    cwebp -quiet -q 75 "$tmp/$base-$w.jpg" -o "$base-$w.webp"
    echo "$base-$w.webp"
  done
}

resize dragon.jpg 640 1000
for f in landrover landrover-2 tractor welding quad; do
  src="$f.jpg"; [ -f "$src" ] || src="$f.webp"
  resize "$src" 640 1200
done
