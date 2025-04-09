#!/bin/bash

# chmod +x build.sh
# ./build.sh

# > Note: Requires pandoc.
# >> brew install pandoc

# > Note: Formatting requires Prettier global install.
# >> sudo npm install -g prettier

PRETTIER_ENABLED=true

INPUT_DIR="${1:-markdown}"
OUTPUT_DIR="${2:-projects}"

if [ ! -d "$INPUT_DIR" ]; then
  echo "🤔 Error: Input directory '$INPUT_DIR' does not exist."
  exit 1
fi

HTML_LAYOUT_FILE="${4:-templates/layout.frag.html}"

if [ ! -f "$HTML_LAYOUT_FILE" ]; then
  echo "🤔 Error: Layout template '$HTML_LAYOUT_FILE' does not exist."
  exit 1
fi

HTML_LAYOUT=$(<"$HTML_LAYOUT_FILE")

if [ -z "$HTML_LAYOUT" ]; then
  echo "🤔 Error: Layout template is empty."
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

find "$INPUT_DIR" -name "*.md" | while read -r filepath; do
  rel_path="${filepath#$INPUT_DIR/}"
  out_path="$OUTPUT_DIR/${rel_path%.md}.html"
  out_dir=$(dirname "$out_path")
  title=$(basename "${rel_path%.md}")

  # Encode path as URL-safe string (strip newlines to avoid trailing %0A)
  url="$(dirname "$rel_path")/$(basename "${rel_path%.md}" | tr -d '\n' | jq -sRr @uri).html"
  # Extract first non-empty line, remove quotes, and limit to 160 characters (meta description limit)
  description=$(grep -m 1 '.' "$filepath" | sed 's/[\"\x27]//g' | cut -c1-160)

  mkdir -p "$out_dir"

  body=$(pandoc "$filepath")

  # Replace {{TITLE}} in the Layout HTML template with the filename of the Markdown file being processed
  layout=$(echo "${HTML_LAYOUT//\{\{TITLE\}\}/$title}")
  # Replace {{DESCRIPTION}} in the Layout HTML template with the first non-empty line of the Markdown file being processed
  layout=$(echo "${layout//\{\{DESCRIPTION\}\}/$description}")
  # Replace {{BODY}} in the Layout HTML template with the contents of the Markdown file being processed
  layout=$(echo "${layout//\{\{BODY\}\}/$body}")
  # Replace {{URL}} in the Layout HTML template with the URL of the Markdown file being processed
  layout=$(echo "${layout//\{\{URL\}\}/$url}")

  echo "$layout" > "$out_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$out_path"
  fi

  echo "🔨🤠 Generated HTML: $out_path"
done