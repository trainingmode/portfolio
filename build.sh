#!/bin/bash

# chmod +x build.sh
# ./build.sh

# > Note: Requires pandoc.
# >> brew install pandoc

# > Note: Formatting requires Prettier global install.
# >> sudo npm install -g prettier

PRETTIER_ENABLED=true

INPUT_DIRECTORY="${1:-markdown}"
OUTPUT_DIRECTORY="${2:-projects}"

if [ ! -d "$INPUT_DIRECTORY" ]; then
  echo "ERROR: Input directory '$INPUT_DIRECTORY' does not exist."
  exit 1
fi

HTML_LAYOUT_FILE="${4:-templates/layout.frag.html}"

if [ ! -f "$HTML_LAYOUT_FILE" ]; then
  echo "ERROR: Layout template '$HTML_LAYOUT_FILE' does not exist."
  exit 1
fi

HTML_LAYOUT=$(<"$HTML_LAYOUT_FILE")

if [ -z "$HTML_LAYOUT" ]; then
  echo "ERROR: Layout template is empty."
  exit 1
fi

mkdir -p "$OUTPUT_DIRECTORY"

find "$INPUT_DIRECTORY" -name "*.md" | while read -r filepath; do
  path_relative="${filepath#$INPUT_DIRECTORY/}"
  output_path="$OUTPUT_DIRECTORY/${path_relative%.md}.html"
  output_directory=$(dirname "$output_path")
  title=$(basename "${path_relative%.md}")

  # Encode path as URL-safe string (strip newlines to avoid trailing %0A)
  url="$(dirname "$path_relative")/$(basename "${path_relative%.md}" | tr -d '\n' | jq -sRr @uri).html"
  # Extract first non-empty line, remove quotes, and limit to 160 characters (meta description limit)
  description=$(grep -m 1 '.' "$filepath" | sed 's/[\"\x27]//g' | cut -c1-160)

  mkdir -p "$output_directory"

  body=$(pandoc "$filepath")

  # Replace {{TITLE}} in the Layout HTML template with the filename of the Markdown file being processed
  layout=$(echo "${HTML_LAYOUT//\{\{TITLE\}\}/$title}")
  # Replace {{DESCRIPTION}} in the Layout HTML template with the first line of content in the Markdown file being processed
  layout=$(echo "${layout//\{\{DESCRIPTION\}\}/$description}")
  # Replace {{BODY}} in the Layout HTML template with the contents of the Markdown file being processed
  layout=$(echo "${layout//\{\{BODY\}\}/$body}")
  # Replace {{URL}} in the Layout HTML template with the URL of the Markdown file being processed
  layout=$(echo "${layout//\{\{URL\}\}/$url}")

  echo "$layout" > "$output_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$output_path"
  fi

  echo "🔨🤠 GENERATED: $output_path"
done