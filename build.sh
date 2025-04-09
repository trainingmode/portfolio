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

HTML_DIRECTORY_FILE="${8:-templates/directory.frag.html}"
if [ ! -f "$HTML_DIRECTORY_FILE" ]; then
  echo "ERROR: Directory template '$HTML_DIRECTORY_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY=$(<"$HTML_DIRECTORY_FILE")
if [ -z "$HTML_DIRECTORY" ]; then
  echo "ERROR: Directory template is empty."
  exit 1
fi

HTML_DIRECTORY_ITEM_FILE="${9:-templates/directory-item.frag.html}"
if [ ! -f "$HTML_DIRECTORY_ITEM_FILE" ]; then
  echo "ERROR: Directory item template '$HTML_DIRECTORY_ITEM_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_ITEM=$(<"$HTML_DIRECTORY_ITEM_FILE")
if [ -z "$HTML_DIRECTORY_ITEM" ]; then
  echo "ERROR: Directory item template is empty."
  exit 1
fi

# Build Articles

mkdir -p "$OUTPUT_DIRECTORY"

find "$INPUT_DIRECTORY" -name "*.md" | while read -r filepath; do
  path_relative="${filepath#$INPUT_DIRECTORY/}"
  slug="${path_relative%.md}"
  output_directory="$OUTPUT_DIRECTORY/${slug}"
  output_path="$output_directory/index.html"
  title=$(basename "${slug}")
  page_title="$title$PAGE_TITLE_SUFFIX"

  # Encode Path as URL-Safe String (Strip Newlines to Avoid Trailing %0A)
  url="$(dirname "$path_relative")/$(basename "${path_relative%.md}" | tr -d '\n' | jq -sRr @uri).html"
  # Extract First Non-Empty Line, Remove Quotes, and Limit to 160 Characters (Meta Description Limit)
  description=$(grep -m 1 '.' "$filepath" | sed 's/[\"\x27]//g' | cut -c1-160)

  mkdir -p "$output_directory"

  body=$(pandoc "$filepath")

  # Replace {{HEAD}} in the Layout HTML Template with the Contents of the Head HTML Template
  layout=$(echo "${HTML_LAYOUT//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML Template with the Contents of the Body HTML Template
  layout="${layout//\{\{BODY\}\}/$HTML_BODY}"
  # Replace {{FOOTER}} in the Layout HTML Template with the Contents of the Footer HTML Template
  layout="${layout//\{\{FOOTER\}\}/$HTML_FOOTER}"

  layout="${layout//\{\{PAGE_TITLE\}\}/$page_title}"
  layout="${layout//\{\{TITLE\}\}/$title}"
  layout="${layout//\{\{DESCRIPTION\}\}/$description}"
  layout="${layout//\{\{MARKDOWN\}\}/$body}"
  layout="${layout//\{\{URL\}\}/$url}"

  # Replace {{YEAR}} in the Layout HTML Template with the Current Year
  layout="${layout//\{\{YEAR\}\}/$(date +%Y)}"

  echo "$layout" > "$output_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$output_path"
  fi

  echo "🔨🤠 GENERATED: $output_path"
done

# Build Directory Indexes

find "$OUTPUT_DIRECTORY" -type d | while read -r directory; do
  # Determine Articles by Counting Subfolders Within a Directory (Articles Only Contain a Single index.html)
  if [ -f "$directory/index.html" ]; then
    folder_count=$(find "$directory" -mindepth 1 -maxdepth 1 -type d | wc -l)
    if [ "$folder_count" -eq 0 ]; then
      continue
    fi
  fi

  directory_relative="${directory#$OUTPUT_DIRECTORY/}"
  page_title="${directory_relative}${PAGE_TITLE_SUFFIX}"

  article_links=""
  for subdirectory in "$directory"/*/; do
    [ ! -d "$subdirectory" ] && continue # Skip Empty Directories

    slug=$(basename "$subdirectory")
    href="/${subdirectory}"

    directory_item="${HTML_DIRECTORY_ITEM//\{\{ARTICLE_HREF\}\}/$href}"
    directory_item="${directory_item//\{\{ARTICLE_TITLE\}\}/$slug}"
    article_links+="$directory_item"
  done

  placeholder="<p class='size-full text-gray-500 text-center'>No articles found in this directory.</p>"
  articles="${article_links:-$placeholder}"

  body="${HTML_DIRECTORY//\{\{DIRECTORY\}\}/$directory}"
  body="${body//\{\{ARTICLES\}\}/$articles}"

  # Replace {{HEAD}} in the Layout HTML Template with the Contents of the Head HTML Template
  layout=$(echo "${HTML_LAYOUT//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML Template with the Contents of the Populated Directory HTML Template
  layout="${layout//\{\{BODY\}\}/$body}"
  # Replace {{FOOTER}} in the Layout HTML Template with the Contents of the Footer HTML Template
  layout="${layout//\{\{FOOTER\}\}/$HTML_FOOTER}"

  layout="${layout//\{\{PAGE_TITLE\}\}/$page_title}"
  layout="${layout//\{\{DESCRIPTION\}\}/Directory index for $directory_relative}"
  layout="${layout//\{\{URL\}\}/$directory_relative}"

  # Replace {{YEAR}} in the Layout HTML Template with the Current Year
  layout="${layout//\{\{YEAR\}\}/$(date +%Y)}"

  output_path="$directory/index.html"
  echo "$layout" > "$output_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$output_path"
  fi

  echo "🔨🤠 GENERATED DIRECTORY: $output_path"
done

# Development Server

if [ -n "$DEV_SERVER_PORT" ]; then
  if command -v serve &> /dev/null; then
    serve -p "$DEV_SERVER_PORT"
  else
    python3 -m http.server "$DEV_SERVER_PORT"
  fi
fi
