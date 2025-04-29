#!/opt/homebrew/bin/bash

# chmod +x build.sh
# ./build.sh

# > Note: Requires Bash >4.
# >> brew install bash

# > Note: Requires Pandoc.
# >> brew install pandoc

# > Note: Formatting requires Prettier global install.
# >> sudo npm install -g prettier

CONFIG_FILE="${1:-ssg.config}"
INPUT_DIRECTORY="${2:-markdown}"
OUTPUT_DIRECTORY="${3:-build}"
TEMPLATE_DIRECTORY="${4:-templates}"

if [ ! -d "$INPUT_DIRECTORY" ]; then
  echo "ERROR: Input directory '$INPUT_DIRECTORY' does not exist."
  exit 1
fi

if [ ! -f "$CONFIG_FILE" ]; then
  echo "🧐 CONFIG: No config file found. Creating a default config..."

  cat <<EOF > "$CONFIG_FILE"
# SASHA — Configuration

# — Site Settings —
DOMAIN="https://alfred.ad"
PAGE_TITLE_SUFFIX=" | SASHA | Static Site Generator"
AUTHOR="SASHA"
X_HANDLE="@trainingmodedev"

# — Build Settings —
PRETTIER_ENABLED=true
PURGE_BUILD_FOLDER=true
SLUGIFY_ENABLED=true

# — Default Images —
DEFAULT_META_IMAGE="/public/og-image.png"
DEFAULT_ARTICLE_IMAGE=""

# — Development Server —
PORT=3000
EOF

  echo "✍️🤠 CONFIG: $CONFIG_FILE has been created. Edit the config to setup your site."
fi
source "$CONFIG_FILE"

# HTML Template Fragment Filenames
HTML_LAYOUT_FILENAME="layout.frag.html"
HTML_HEAD_FILENAME="head.frag.html"
HTML_BODY_FILENAME="body.frag.html"
HTML_FOOTER_FILENAME="footer.frag.html"
HTML_DIRECTORY_FILENAME="directory.frag.html"
HTML_DIRECTORY_CRUMB_FILENAME="directory-crumb.frag.html"
HTML_DIRECTORY_ARTICLE_FILENAME="listing-article.frag.html"
HTML_DIRECTORY_PINNED_ARTICLE_FILENAME="listing-pinned.frag.html"
HTML_DIRECTORY_FOLDER_FILENAME="listing-folder.frag.html"
HTML_DOWNLOAD_LINK_FILENAME="download-link.frag.html"
HTML_EMAIL_LINK_FILENAME="email-link.frag.html"
HTML_IFRAME_FILENAME="iframe.frag.html"
HTML_IMG_COMPARISON_FILENAME="img-compare.frag.html"
HTML_VIDEO_FILENAME="video.frag.html"

HTML_LAYOUT_FILE="${TEMPLATE_DIRECTORY}/${HTML_LAYOUT_FILENAME}"
if [ ! -f "$HTML_LAYOUT_FILE" ]; then
  echo "ERROR: Layout template '$HTML_LAYOUT_FILE' does not exist."
  exit 1
fi
HTML_LAYOUT=$(<"$HTML_LAYOUT_FILE")
if [ -z "$HTML_LAYOUT" ]; then
  echo "ERROR: Layout template is empty."
  exit 1
fi

HTML_HEAD_FILE="${TEMPLATE_DIRECTORY}/${HTML_HEAD_FILENAME}"
if [ ! -f "$HTML_HEAD_FILE" ]; then
  echo "ERROR: Head template '$HTML_HEAD_FILE' does not exist."
  exit 1
fi
HTML_HEAD=$(<"$HTML_HEAD_FILE")
if [ -z "$HTML_HEAD" ]; then
  echo "ERROR: Head template is empty."
  exit 1
fi

HTML_BODY_FILE="${TEMPLATE_DIRECTORY}/${HTML_BODY_FILENAME}"
if [ ! -f "$HTML_BODY_FILE" ]; then
  echo "ERROR: Body template '$HTML_BODY_FILE' does not exist."
  exit 1
fi
HTML_BODY=$(<"$HTML_BODY_FILE")
if [ -z "$HTML_BODY" ]; then
  echo "ERROR: Body template is empty."
  exit 1
fi

HTML_FOOTER_FILE="${TEMPLATE_DIRECTORY}/${HTML_FOOTER_FILENAME}"
if [ ! -f "$HTML_FOOTER_FILE" ]; then
  echo "ERROR: Footer template '$HTML_FOOTER_FILE' does not exist."
  exit 1
fi
HTML_FOOTER=$(<"$HTML_FOOTER_FILE")
if [ -z "$HTML_FOOTER" ]; then
  echo "ERROR: Footer template is empty."
  exit 1
fi

HTML_DIRECTORY_FILE="${TEMPLATE_DIRECTORY}/${HTML_DIRECTORY_FILENAME}"
if [ ! -f "$HTML_DIRECTORY_FILE" ]; then
  echo "ERROR: Directory template '$HTML_DIRECTORY_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY=$(<"$HTML_DIRECTORY_FILE")
if [ -z "$HTML_DIRECTORY" ]; then
  echo "ERROR: Directory template is empty."
  exit 1
fi

HTML_DIRECTORY_CRUMB_FILE="${TEMPLATE_DIRECTORY}/${HTML_DIRECTORY_CRUMB_FILENAME}"
if [ ! -f "$HTML_DIRECTORY_CRUMB_FILE" ]; then
  echo "ERROR: Directory crumb template '$HTML_DIRECTORY_CRUMB_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_CRUMB=$(<"$HTML_DIRECTORY_CRUMB_FILE")
if [ -z "$HTML_DIRECTORY_CRUMB" ]; then
  echo "ERROR: Directory crumb template is empty."
  exit 1
fi

HTML_DIRECTORY_ARTICLE_FILE="${TEMPLATE_DIRECTORY}/${HTML_DIRECTORY_ARTICLE_FILENAME}"
if [ ! -f "$HTML_DIRECTORY_ARTICLE_FILE" ]; then
  echo "ERROR: Directory article listing template '$HTML_DIRECTORY_ARTICLE_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_ARTICLE=$(<"$HTML_DIRECTORY_ARTICLE_FILE")
if [ -z "$HTML_DIRECTORY_ARTICLE" ]; then
  echo "ERROR: Directory article listing template is empty."
  exit 1
fi

HTML_DIRECTORY_PINNED_ARTICLE_FILE="${TEMPLATE_DIRECTORY}/${HTML_DIRECTORY_PINNED_ARTICLE_FILENAME}"
if [ ! -f "$HTML_DIRECTORY_PINNED_ARTICLE_FILE" ]; then
  echo "ERROR: Directory pinned article listing template '$HTML_DIRECTORY_PINNED_ARTICLE_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_PINNED_ARTICLE=$(<"$HTML_DIRECTORY_PINNED_ARTICLE_FILE")
if [ -z "$HTML_DIRECTORY_PINNED_ARTICLE" ]; then
  echo "ERROR: Directory pinned article listing template is empty."
  exit 1
fi

HTML_DIRECTORY_FOLDER_FILE="${TEMPLATE_DIRECTORY}/${HTML_DIRECTORY_FOLDER_FILENAME}"
if [ ! -f "$HTML_DIRECTORY_FOLDER_FILE" ]; then
  echo "ERROR: Directory folder listing template '$HTML_DIRECTORY_FOLDER_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_FOLDER=$(<"$HTML_DIRECTORY_FOLDER_FILE")
if [ -z "$HTML_DIRECTORY_FOLDER" ]; then
  echo "ERROR: Directory folder listing template is empty."
  exit 1
fi

HTML_DOWNLOAD_LINK_FILE="${TEMPLATE_DIRECTORY}/${HTML_DOWNLOAD_LINK_FILENAME}"
if [ ! -f "$HTML_DOWNLOAD_LINK_FILE" ]; then
  echo "ERROR: Download button template '$HTML_DOWNLOAD_LINK_FILE' does not exist."
  exit 1
fi
HTML_DOWNLOAD_LINK=$(<"$HTML_DOWNLOAD_LINK_FILE")
if [ -z "$HTML_DOWNLOAD_LINK" ]; then
  echo "ERROR: Download button template is empty."
  exit 1
fi
HTML_DOWNLOAD_LINK=$(tr -d '\n' < "$HTML_DOWNLOAD_LINK_FILE") # Strip Newlines for sed RegEx Replacement
HTML_DOWNLOAD_LINK="${HTML_DOWNLOAD_LINK//&/\\&}" # Escape All & Ampersands for sed RegEx Replacement
# Substitute {{DOWNLOAD_LINK_ALT}}, {{DOWNLOAD_LINK_SRC}}, & {{DOWNLOAD_LINK_TITLE}} in the Download Button HTML Template for the sed RegEx Replacement
HTML_DOWNLOAD_LINK="${HTML_DOWNLOAD_LINK//\{\{DOWNLOAD_LINK_ALT\}\}/\\1}"
HTML_DOWNLOAD_LINK="${HTML_DOWNLOAD_LINK//\{\{DOWNLOAD_LINK_SRC\}\}/\\2}"
HTML_DOWNLOAD_LINK="${HTML_DOWNLOAD_LINK//\{\{DOWNLOAD_LINK_TITLE\}\}/\\3}"

HTML_EMAIL_LINK_FILE="${TEMPLATE_DIRECTORY}/${HTML_EMAIL_LINK_FILENAME}"
if [ ! -f "$HTML_EMAIL_LINK_FILE" ]; then
  echo "ERROR: Email button template '$HTML_EMAIL_LINK_FILE' does not exist."
  exit 1
fi
HTML_EMAIL_LINK=$(<"$HTML_EMAIL_LINK_FILE")
if [ -z "$HTML_EMAIL_LINK" ]; then
  echo "ERROR: Email button template is empty."
  echo "Proceeding with default email link output."
fi
HTML_EMAIL_LINK=$(tr -d '\n' < "$HTML_EMAIL_LINK_FILE") # Strip Newlines for sed RegEx Replacement
HTML_EMAIL_LINK="${HTML_EMAIL_LINK//&/\\&}" # Escape All & Ampersands for sed RegEx Replacement
# Substitute {{EMAIL_LINK_SRC}}, {{EMAIL_LINK_ALT}}, & {{EMAIL_LINK_TITLE}} in the Email Button HTML Template for the sed RegEx Replacement
HTML_EMAIL_LINK="${HTML_EMAIL_LINK//\{\{EMAIL_LINK_ALT\}\}/\\1}"
HTML_EMAIL_LINK="${HTML_EMAIL_LINK//\{\{EMAIL_LINK_SRC\}\}/\\2}"
HTML_EMAIL_LINK="${HTML_EMAIL_LINK//\{\{EMAIL_LINK_TITLE\}\}/\\3}"


HTML_IFRAME_FILE="${TEMPLATE_DIRECTORY}/${HTML_IFRAME_FILENAME}"
if [ ! -f "$HTML_IFRAME_FILE" ]; then
  echo "ERROR: IFrame template '$HTML_IFRAME_FILE' does not exist."
  exit 1
fi
HTML_IFRAME=$(tr -d '\n' < "$HTML_IFRAME_FILE") # Strip Newlines for sed RegEx Replacement
# Substitute {{IFRAME_SRC}} & {{IFRAME_HEIGHT}} in the IFrame HTML Template for the sed RegEx Replacement
HTML_IFRAME="${HTML_IFRAME//\{\{IFRAME_HEIGHT\}\}/\\1}"
HTML_IFRAME="${HTML_IFRAME//\{\{IFRAME_SRC\}\}/\\2}"

HTML_IMG_COMPARISON_FILE="${TEMPLATE_DIRECTORY}/${HTML_IMG_COMPARISON_FILENAME}"
if [ ! -f "$HTML_IMG_COMPARISON_FILE" ]; then
  echo "ERROR: Image comparison template '$HTML_IMG_COMPARISON_FILE' does not exist."
  exit 1
fi
HTML_IMG_COMPARISON=$(tr -d '\n' < "${HTML_IMG_COMPARISON_FILE}") # Strip Newlines for sed RegEx Replacement
HTML_IMG_COMPARISON="${HTML_IMG_COMPARISON//&/\\&}" # Escape All & Ampersands for sed RegEx Replacement
# Substitute {{IMG_COMPARE_ALTX}} & {{IMG_COMPARE_SRCX}} in the Image Comparison HTML Template for the sed RegEx Replacement
HTML_IMG_COMPARISON="${HTML_IMG_COMPARISON//\{\{IMG_COMPARE_ALT1\}\}/\\1}"
HTML_IMG_COMPARISON="${HTML_IMG_COMPARISON//\{\{IMG_COMPARE_SRC1\}\}/\\2}"
HTML_IMG_COMPARISON="${HTML_IMG_COMPARISON//\{\{IMG_COMPARE_ALT2\}\}/\\3}"
HTML_IMG_COMPARISON="${HTML_IMG_COMPARISON//\{\{IMG_COMPARE_SRC2\}\}/\\4}"

HTML_VIDEO_FILE="${TEMPLATE_DIRECTORY}/${HTML_VIDEO_FILENAME}"
if [ ! -f "$HTML_VIDEO_FILE" ]; then
  echo "ERROR: Video template '$HTML_VIDEO_FILE' does not exist."
  exit 1
fi
HTML_VIDEO=$(tr -d '\n' < "$HTML_VIDEO_FILE") # Strip Newlines for sed RegEx Replacement
HTML_VIDEO="${HTML_VIDEO//&/\\&}" # Escape All & Ampersands for sed RegEx Replacement
# Substitute {{VIDEO_ATTRIBUTES}}, {{VIDEO_SOURCE}}, & {{VIDEO_TYPE}} in the Video HTML Template for the sed RegEx Replacement
HTML_VIDEO="${HTML_VIDEO//\{\{VIDEO_ATTRIBUTES\}\}/\\1}"
HTML_VIDEO="${HTML_VIDEO//\{\{VIDEO_SOURCE\}\}/\\2}"
HTML_VIDEO="${HTML_VIDEO//\{\{VIDEO_TYPE\}\}/\\3}"

# Remove Leftover Temp Files
rm -f ~tmp.XXXXXX*

# Purge Build Folder

if [ "$PURGE_BUILD_FOLDER" = true ]; then
  echo "🧹😮‍💨 CLEANUP: Removing build folder '$OUTPUT_DIRECTORY'."
  rm -rf "$OUTPUT_DIRECTORY"
fi

# Build Articles

declare -A article_lut
declare -A article_images
declare -A article_descriptions
declare -A pinned_articles
declare -A hidden_articles

mkdir -p "$OUTPUT_DIRECTORY"

while read -r filepath; do
  # Determine if the Article is Skipped
  if [ "$(basename "${filepath}" | cut -c1)" = "_" ]; then
    continue
  fi

  # Determine if the Article is Hidden
  if [ "$(basename "${filepath}" | cut -c1)" = "~" ]; then
    filename_cleansed=$(basename "$filepath" | sed 's/^[~ ]*//')
    filepath_cleansed="$(dirname "$filepath")/$filename_cleansed"
    hidden=true
  else
    filepath_cleansed="$filepath"
    hidden=false
  fi

  # Determine if the Article is Pinned
  if [ "$(basename "${filepath_cleansed}" | cut -c1)" = "*" ]; then
    filename_cleansed=$(basename "$filepath_cleansed" | sed 's/^[* ]*//')
    filepath_cleansed="$(dirname "$filepath_cleansed")/$filename_cleansed"
    pinned=true
  else
    pinned=false
  fi

  path_relative="${filepath_cleansed#$INPUT_DIRECTORY/}"
  slug="${path_relative%.md}"
  title=$(basename "${slug}")
  if [ "$SLUGIFY_ENABLED" = true ]; then
    slug=${slug,,} # Convert to Lowercase
    slug=${slug//[^a-z0-9\/]/-} # Replace Non-Alphanumeric (+ Non-Forwardslash) Characters with Hyphens
    slug=$(echo "$slug" | tr -s '-') # Replace Multiple Consecutive Hyphens with a Single Hyphen
    slug=${slug##-}; slug=${slug%%-} # Remove Leading & Trailing Hyphens
  fi
  output_directory="$OUTPUT_DIRECTORY/${slug}"
  output_path="$output_directory/index.html"
  page_title="$title$PAGE_TITLE_SUFFIX"

  # Encode Path as URL-Safe String (Strip Newlines to Avoid Trailing %0A)
  url="$DOMAIN/$OUTPUT_DIRECTORY/$(dirname "$path_relative")/$(basename "${path_relative%.md}" | tr -d '\n' | jq -sRr @uri).html"
  # Extract First Non-Empty Line
  first_line=$(grep -m 1 '.' "$filepath")
  # Limit First Non-Empty Line to 160 Characters (Meta Description Limit)
  description="${first_line:0:160}"
  # Use First Line as Hero Image if Starts with ![
  if [ "${first_line:0:2}" = "![" ]; then
    read meta_image meta_title < <(
      sed -n -n 's/.*](\([^ ]*\) "\([^"]*\)").*/\1 \2/p' <<< "$first_line"  # Extract the URL & Title Between the )[, ", and "] Character Sequences
    )
    # Store Extracted Article Image for Directory Item
    article_images["$output_directory"]="$meta_image"
    # Extract the Second Non-Empty Line as the Description
    description=$(grep -m 2 '.' "$filepath" | tail -n 1 | cut -c1-160) # tail Gets the Second Non-Empty Line (why would they call it that...)
    # Sanitize the Description (& Prevent Reinjection)
    description="${description//&/\\&}"
    # Trim Leading Markdown Block Characters (#, >)
    description="${description#[\#> ] }"
    # Store Extracted Article Description for Directory Item
    article_descriptions["$output_directory"]="$description"
  else
    meta_image="$DEFAULT_META_IMAGE"
  fi
  # Mark the Article as Hidden if its Original Filename Started with ~
  hidden_articles["$output_directory"]="$hidden"
  # Mark the Article as Pinned if its Original Filename Started with *
  if [ "$pinned" = true ]; then
    pinned_articles["$output_directory"]="$title"
  fi

  mkdir -p "$output_directory"

  # Preprocess Embedded iFrames @[height](url)
  preprocessed=$(mktemp ~tmp.XXXXXX.md)
  # Syntax: @[height](url)
  sed -E "s|@\[([^]]+)\]\(([^)]+)\)|${HTML_IFRAME}|g" "$filepath" > "$preprocessed"

  # Preprocess Download Links +[alt](url "title")
  sed -i "" -E 's|\+\[([^]]+)\]\(([^ ]+) "([^"]+)"\)|'"$HTML_DOWNLOAD_LINK"'|g' "$preprocessed"

  # Preprocess Email Links [alt](mailto:url "title")
  sed -i "" -E 's|\[([^]]+)\]\(mailto:([^ ]+) "([^"]+)"\)|'"$HTML_EMAIL_LINK"'|g' "$preprocessed"

  # Preprocess Embedded Image Comparisons %[alt](url)\n%[alt](url) (Use N; to Match Multiple Lines)
  sed -i "" -E "N;s|%\[([^]]+)\]\(([^)]+)\)\n%\[([^]]+)\]\(([^)]+)\)|${HTML_IMG_COMPARISON}|g" "$preprocessed"

  # Preprocess Embedded Videos ~[attributes](url "type")
  sed -i "" -E "s|~\[([^]]+)\]\(([^)]+) \"([^)]+)\"\)|$HTML_VIDEO|g" "$preprocessed"

  # Process the Markdown Article
  body=$(pandoc "$preprocessed")
  rm "$preprocessed"

  # Replace {{HEAD}} in the Layout HTML Template with the Contents of the Head HTML Template
  layout=$(echo "${HTML_LAYOUT//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML Template with the Contents of the Body HTML Template
  layout="${layout//\{\{BODY\}\}/$HTML_BODY}"
  # Replace {{FOOTER}} in the Layout HTML Template with the Contents of the Footer HTML Template
  layout="${layout//\{\{FOOTER\}\}/$HTML_FOOTER}"

  layout="${layout//\{\{PAGE_TITLE\}\}/$page_title}"
  layout="${layout//\{\{TITLE\}\}/$title}"
  layout="${layout//\{\{AUTHOR\}\}/$AUTHOR}"
  layout="${layout//\{\{X_HANDLE\}\}/$X_HANDLE}"
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

  article_lut["$output_directory"]="$title"
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
  url="$DOMAIN/$OUTPUT_DIRECTORY/$directory_relative"

  folder_links=""
  article_links=""
  pinned_article_links=""
  hidden_article_links=""
  for subdirectory in "$directory"/*/; do
    [ ! -d "$subdirectory" ] && continue # Skip Empty Directories

    slug=$(basename "$subdirectory")
    href="/${subdirectory}"

    article_image="${article_images["${subdirectory%/}"]}"
    if [ -z "$article_image" ]; then
      article_image="$DEFAULT_ARTICLE_IMAGE"
    fi

    article_description="${article_descriptions["${subdirectory%/}"]}"
    if [ -z "$article_description" ]; then
      article_description="$directory_relative"
    fi

    # Determine the Listing Template to Apply
    if [ -n "${pinned_articles["${subdirectory%/}"]}" ]; then
      slug="${pinned_articles["${subdirectory%/}"]}"
      folder_listing=false
      pinned_listing=true
      default_listing_template="$HTML_DIRECTORY_PINNED_ARTICLE"
      listing_template_path="templates/$directory_relative/$HTML_DIRECTORY_PINNED_ARTICLE_FILENAME"
    elif [ -n "${article_lut["${subdirectory%/}"]}" ]; then
      slug="${article_lut["${subdirectory%/}"]}"
      folder_listing=false
      pinned_listing=false
      default_listing_template="$HTML_DIRECTORY_ARTICLE"
      listing_template_path="templates/$directory_relative/$HTML_DIRECTORY_ARTICLE_FILENAME"
    else
      folder_listing=true
      pinned_listing=false
      default_listing_template="$HTML_DIRECTORY_FOLDER"
      listing_template_path="templates/$directory_relative/$HTML_DIRECTORY_FOLDER_FILENAME"
    fi

    if [ -f "$listing_template_path" ]; then
      listing_template=$(<"$listing_template_path")
    else
      listing_template="$default_listing_template"
    fi

    directory_item="${listing_template//\{\{ARTICLE_HREF\}\}/$href}"
    directory_item="${directory_item//\{\{ARTICLE_TITLE\}\}/$slug}"
    directory_item="${directory_item//\{\{ARTICLE_DESCRIPTION\}\}/$article_description}"
    directory_item="${directory_item//\{\{ARTICLE_IMAGE\}\}/$article_image}"
    # Sanitize the Directory Item (& Prevent Reinjection)
    directory_item="${directory_item//&/\\&}"

    if [ "${hidden_articles["${subdirectory%/}"]}" = true ]; then
      hidden_article_links+="$directory_item"
    elif [ "$folder_listing" = true ]; then
      folder_links+="$directory_item"
    elif [ "$pinned_listing" = true ]; then
      pinned_article_links+="$directory_item"
    else
      article_links+="$directory_item"
    fi
  done

  placeholder="<p class='col-span-full size-full text-neutral-500 text-center'>No articles found in this directory.</p>"
  folders_listing="${folder_links}"
  pinned_articles="${pinned_article_links}"
  hidden_articles="${hidden_article_links}"
  if [ -z "$pinned_articles" ] && [ -z "$folders_listing" ]; then
    articles_listing="${article_links:-$placeholder}"
  else
    articles_listing="${article_links}"
  fi

  # Parent Directory
  parent_directory_href="/$(dirname "$directory")"
  parent_listing="${HTML_DIRECTORY_FOLDER//\{\{ARTICLE_HREF\}\}/$parent_directory_href}"
  parent_listing="${parent_listing//\{\{ARTICLE_TITLE\}\}/$(basename "$parent_directory_href")}"
  parent_listing="${parent_listing//\{\{ARTICLE_IMAGE\}\}/$DEFAULT_ARTICLE_IMAGE}"

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

  # Check if Directory Template Exists in Relative Directory Inside templates/
  directory_template_path="templates/$directory_relative/$HTML_DIRECTORY_FILENAME"
  if [ -f "$directory_template_path" ]; then
    directory_template=$(<"$directory_template_path")
  else
    directory_template="$HTML_DIRECTORY"
  fi

  body="${directory_template//\{\{CRUMBS\}\}/${crumbs[@]}}"
  body="${body//\{\{PINNED_ARTICLES\}\}/$pinned_articles}"
  body="${body//\{\{ARTICLES\}\}/$articles_listing}"
  body="${body//\{\{PARENT_DIRECTORY\}\}/$parent_listing}"
  body="${body//\{\{FOLDERS\}\}/$folders_listing}"
  body="${body//\{\{HIDDEN_ARTICLES\}\}/$hidden_articles}"
  # Sanitize the Body (& Prevent Reinjection)
  body="${body//&/\\&}"

  # Replace {{HEAD}} in the Layout HTML Template with the Contents of the Head HTML Template
  layout=$(echo "${HTML_LAYOUT//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML Template with the Contents of the Populated Directory HTML Template
  layout="${layout//\{\{BODY\}\}/$body}"
  # Replace {{FOOTER}} in the Layout HTML Template with the Contents of the Footer HTML Template
  layout="${layout//\{\{FOOTER\}\}/$HTML_FOOTER}"

  layout="${layout//\{\{PAGE_TITLE\}\}/$page_title}"
  layout="${layout//\{\{AUTHOR\}\}/$AUTHOR}"
  layout="${layout//\{\{X_HANDLE\}\}/$X_HANDLE}"
  layout="${layout//\{\{DESCRIPTION\}\}/Directory index for $directory_relative}"
  layout="${layout//\{\{URL\}\}/$url}"

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
