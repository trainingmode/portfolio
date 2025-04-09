#!/bin/bash

# chmod +x build.sh
# ./build.sh

# > Note: Requires pandoc.
# >> brew install pandoc

# > Note: Formatting requires Prettier global install.
# >> sudo npm install -g prettier

PAGE_TITLE_SUFFIX=" | Alfred R. Duarte | Portfolio"

PRETTIER_ENABLED=true

DEV_SERVER_PORT="${1}"

INPUT_DIRECTORY="${2:-markdown}"
OUTPUT_DIRECTORY="${3:-projects}"

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

HTML_HEAD_FILE="${5:-templates/head.frag.html}"
if [ ! -f "$HTML_HEAD_FILE" ]; then
  echo "ERROR: Head template '$HTML_HEAD_FILE' does not exist."
  exit 1
fi
HTML_HEAD=$(<"$HTML_HEAD_FILE")
if [ -z "$HTML_HEAD" ]; then
  echo "ERROR: Head template is empty."
  exit 1
fi

HTML_BODY_FILE="${6:-templates/body.frag.html}"
if [ ! -f "$HTML_BODY_FILE" ]; then
  echo "ERROR: Body template '$HTML_BODY_FILE' does not exist."
  exit 1
fi
HTML_BODY=$(<"$HTML_BODY_FILE")
if [ -z "$HTML_BODY" ]; then
  echo "ERROR: Body template is empty."
  exit 1
fi

HTML_FOOTER_FILE="${7:-templates/footer.frag.html}"
if [ ! -f "$HTML_FOOTER_FILE" ]; then
  echo "ERROR: Footer template '$HTML_FOOTER_FILE' does not exist."
  exit 1
fi
HTML_FOOTER=$(<"$HTML_FOOTER_FILE")
if [ -z "$HTML_FOOTER" ]; then
  echo "ERROR: Footer template is empty."
  exit 1
fi

mkdir -p "$OUTPUT_DIRECTORY"

find "$INPUT_DIRECTORY" -name "*.md" | while read -r filepath; do
  path_relative="${filepath#$INPUT_DIRECTORY/}"
  output_path="$OUTPUT_DIRECTORY/${path_relative%.md}.html"
  output_directory=$(dirname "$output_path")
  title=$(basename "${path_relative%.md}")
  page_title="$title$PAGE_TITLE_SUFFIX"

  # Encode path as URL-safe string (strip newlines to avoid trailing %0A)
  url="$(dirname "$path_relative")/$(basename "${path_relative%.md}" | tr -d '\n' | jq -sRr @uri).html"
  # Extract first non-empty line, remove quotes, and limit to 160 characters (meta description limit)
  description=$(grep -m 1 '.' "$filepath" | sed 's/[\"\x27]//g' | cut -c1-160)

  mkdir -p "$output_directory"

  body=$(pandoc "$filepath")

  # Replace {{HEAD}} in the Layout HTML template with the contents of the Head HTML template
  layout=$(echo "${HTML_LAYOUT//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML template with the contents of the Body HTML template
  layout=$(echo "${layout//\{\{BODY\}\}/$HTML_BODY}")
  # Replace {{FOOTER}} in the Layout HTML template with the contents of the Footer HTML template
  layout=$(echo "${layout//\{\{FOOTER\}\}/$HTML_FOOTER}")

  # Replace {{PAGE_TITLE}} in the Layout HTML template with the filename of the Markdown file being processed
  layout=$(echo "${layout//\{\{PAGE_TITLE\}\}/$page_title}")
  # Replace {{TITLE}} in the Layout HTML template with the filename of the Markdown file being processed
  layout=$(echo "${layout//\{\{TITLE\}\}/$title}")
  # Replace {{DESCRIPTION}} in the Layout HTML template with the first line of content in the Markdown file being processed
  layout=$(echo "${layout//\{\{DESCRIPTION\}\}/$description}")
  # Replace {{MARKDOWN}} in the Layout HTML template with the contents of the Markdown file being processed
  layout=$(echo "${layout//\{\{MARKDOWN\}\}/$body}")
  # Replace {{URL}} in the Layout HTML template with the URL of the Markdown file being processed
  layout=$(echo "${layout//\{\{URL\}\}/$url}")

  # Replace {{YEAR}} in the Layout HTML template with the current year
  layout=$(echo "${layout//\{\{YEAR\}\}/$(date +%Y)}")

  echo "$layout" > "$output_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$output_path"
  fi

  echo "🔨🤠 GENERATED: $output_path"
done

if [ -n "$DEV_SERVER_PORT" ]; then
  if command -v serve &> /dev/null; then
    serve -p "$DEV_SERVER_PORT"
  else
    python3 -m http.server "$DEV_SERVER_PORT"
  fi
fi
