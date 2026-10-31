#!/usr/bin/env bash
# Downloads one freely licensed photo per search term from Wikimedia Commons
# into images/ and records licence + author in images/CREDITS.md.
# Review each picture afterwards: swap any that don't fit by editing the terms below.
set -eu
cd "$(dirname "$0")/.."
mkdir -p images
: > images/CREDITS.md
echo "# Image credits" >> images/CREDITS.md

fetch() {
  name="$1"; term="$2"
  json=$(curl -sfG "https://commons.wikimedia.org/w/api.php" \
    --data-urlencode "action=query" --data-urlencode "generator=search" \
    --data-urlencode "gsrnamespace=6" --data-urlencode "gsrsearch=$term filetype:bitmap" \
    --data-urlencode "gsrlimit=3" --data-urlencode "prop=imageinfo" \
    --data-urlencode "iiprop=url|extmetadata" --data-urlencode "iiurlwidth=1600" \
    --data-urlencode "format=json") || return 1
  printf '%s' "$json" | python3 -c '
import json, re, sys
name = sys.argv[1]
pages = json.load(sys.stdin).get("query", {}).get("pages")
if not pages:
    sys.exit(1)
p = min(pages.values(), key=lambda x: x["index"])
i = p["imageinfo"][0]; m = i["extmetadata"]
strip = lambda s: re.sub("<[^>]+>", "", s or "")
print(i["thumburl"])
print("- %s.jpg: %s, %s, %s (%s)" % (name, p["title"], strip(m.get("Artist", {}).get("value")), m.get("LicenseShortName", {}).get("value", "?"), i["descriptionurl"]))
' "$name" > "$TMPDIR/fetch-$name.txt" || return 1
  curl -sfL -A "ak-engineering-site/1.0" -o "images/$name.jpg" "$(sed -n 1p "$TMPDIR/fetch-$name.txt")" || return 1
  sed -n 2p "$TMPDIR/fetch-$name.txt" >> images/CREDITS.md
  echo "got $name"
}

: "${TMPDIR:=/tmp}"
try() { fetch "$@" || echo "no result for $1 (term: $2), try another term"; }
try landrover   "Land Rover Series III"
try landrover-2 "Land Rover Defender 90"
try tractor     "tractor field"
try quad        "quad bike"
try welding     "welding sparks"
try motorcycle  "motorcycle"
