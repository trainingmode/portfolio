#!/opt/homebrew/bin/bash

# chmod +x build.sh
# ./build.sh

# > Note: Requires pandoc.
# >> brew install pandoc

# > Note: Formatting requires Prettier global install.
# >> sudo npm install -g prettier

PAGE_TITLE_SUFFIX=" | Alfred R. Duarte | Portfolio"

PRETTIER_ENABLED=true
PURGE_BUILD_FOLDER=true

DOMAIN="https://alfred.ad"
DEFAULT_META_IMAGE="/public/og-image.png"
DEFAULT_ARTICLE_IMAGE=""

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

HTML_DIRECTORY_CRUMB_FILE="${9:-templates/directory-crumb.frag.html}"
if [ ! -f "$HTML_DIRECTORY_CRUMB_FILE" ]; then
  echo "ERROR: Directory crumb template '$HTML_DIRECTORY_CRUMB_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_CRUMB=$(<"$HTML_DIRECTORY_CRUMB_FILE")
if [ -z "$HTML_DIRECTORY_CRUMB" ]; then
  echo "ERROR: Directory crumb template is empty."
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

# Purge Build Folder

if [ "$PURGE_BUILD_FOLDER" = true ]; then
  echo "🧹😮‍💨 CLEANUP: Removing build folder '$OUTPUT_DIRECTORY'."
  rm -rf "$OUTPUT_DIRECTORY"
fi

# Build Articles

declare -A article_images

mkdir -p "$OUTPUT_DIRECTORY"

while read -r filepath; do
  path_relative="${filepath#$INPUT_DIRECTORY/}"
  slug="${path_relative%.md}"
  output_directory="$OUTPUT_DIRECTORY/${slug}"
  output_path="$output_directory/index.html"
  title=$(basename "${slug}")
  page_title="$title$PAGE_TITLE_SUFFIX"

  # Encode Path as URL-Safe String (Strip Newlines to Avoid Trailing %0A)
  url="$DOMAIN/$OUTPUT_DIRECTORY/$(dirname "$path_relative")/$(basename "${path_relative%.md}" | tr -d '\n' | jq -sRr @uri).html"
  # Extract First Non-Empty Line
  first_line=$(grep -m 1 '.' "$filepath")
  # Limit First Non-Empty Line to 160 Characters (Meta Description Limit)
  description="${first_line:0:160}"
  # Use First Line as Hero Image if Starts with ![
  if [ "${first_line:0:2}" = "![" ]; then
    meta_image=$(echo "$first_line" | sed -n 's/.*](\(.*\))/\1/p') # Extract the URL Between the )[ and ] Character Sequences
    # Extract the Second Non-Empty Line as the Description
    description=$(grep -m 2 '.' "$filepath" | tail -n 1 | cut -c1-160) # tail Gets the Second Non-Empty Line (why would they call it that...)
    # Store Extracted Article Image for Directory Item
    article_images["$output_directory"]="$meta_image"
  else
    meta_image="$DEFAULT_META_IMAGE"
  fi

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
  layout="${layout//\{\{MARKDOWN\}\}/"$body"}"
  layout="${layout//\{\{URL\}\}/$url}"

  # Replace {{YEAR}} in the Layout HTML Template with the Current Year
  layout="${layout//\{\{YEAR\}\}/$(date +%Y)}"
  # Replace {{IMAGE}} in the Layout HTML Template with the Meta Image
  layout="${layout//\{\{IMAGE\}\}/$DOMAIN$meta_image}"

  echo "$layout" > "$output_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$output_path"
  fi

  echo "🔨🤠 GENERATED: $output_path"
done < <(find "$INPUT_DIRECTORY" -name "*.md")

# Build Directory Indexes

while read -r directory; do
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

    article_image="${article_images["${subdirectory%/}"]}"
    if [ -z "$article_image" ]; then
      article_image="$DEFAULT_ARTICLE_IMAGE"
    fi

    directory_item="${HTML_DIRECTORY_ITEM//\{\{ARTICLE_HREF\}\}/$href}"
    directory_item="${directory_item//\{\{ARTICLE_TITLE\}\}/$slug}"
    directory_item="${directory_item//\{\{ARTICLE_IMAGE\}\}/$article_image}"
    article_links+="$directory_item"
  done
  

  placeholder="<p class='size-full text-neutral-500 text-center'>No articles found in this directory.</p>"
  articles="${article_links:-$placeholder}"

  # Breadcrumbs
  crumbs=()
  directory_path="$directory"
  while [[ -n "$directory_path" && "$directory_path" != "/" && "$directory_path" != "." ]]; do # Not Empty, Not Root or Current Directory
    directory_name=$(basename "$directory_path")
    # Replace {{DIRECTORY_HREF}} in the Directory Crumb HTML Template with the Full Directory Path
    crumb="${HTML_DIRECTORY_CRUMB//\{\{DIRECTORY_HREF\}\}/$directory_path}"
    # Replace {{DIRECTORY_NAME}} in the Directory Crumb HTML Template with the Directory Name
    crumb="${crumb//\{\{DIRECTORY_NAME\}\}/$directory_name}"
    crumbs=("$crumb" "${crumbs[@]}")
    # Trim the Directory Name from the Directory Path
    directory_path=$(dirname "$directory_path")
  done
  echo "CRUMBS: ${crumbs[@]}"HTML_DIRECTORY_CRUMB

  body="${HTML_DIRECTORY//\{\{CRUMBS\}\}/${crumbs[@]}}"
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
  # Replace {{IMAGE}} in the Layout HTML Template with the Default Meta Image
  layout="${layout//\{\{IMAGE\}\}/$DOMAIN$DEFAULT_META_IMAGE}"

  output_path="$directory/index.html"
  echo "$layout" > "$output_path"

  if [ "$PRETTIER_ENABLED" = true ]; then
    prettier --write "$output_path"
  fi

  echo "🔨🤠 GENERATED DIRECTORY: $output_path"
done < <(find "$OUTPUT_DIRECTORY" -type d)

# Development Server

if [ -n "$DEV_SERVER_PORT" ]; then
  if command -v serve &> /dev/null; then
    serve -p "$DEV_SERVER_PORT"
  else
    python3 -m http.server "$DEV_SERVER_PORT"
  fi
fi
