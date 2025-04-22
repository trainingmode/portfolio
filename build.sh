#!/opt/homebrew/bin/bash

# chmod +x build.sh
# ./build.sh

# > Note: Requires Bash 4.
# >> brew install bash

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

INPUT_DIRECTORY="${1:-markdown}"
OUTPUT_DIRECTORY="${2:-build}"

if [ ! -d "$INPUT_DIRECTORY" ]; then
  echo "ERROR: Input directory '$INPUT_DIRECTORY' does not exist."
  exit 1
fi

HTML_LAYOUT_FILE="${3:-templates/layout.frag.html}"
if [ ! -f "$HTML_LAYOUT_FILE" ]; then
  echo "ERROR: Layout template '$HTML_LAYOUT_FILE' does not exist."
  exit 1
fi
HTML_LAYOUT=$(<"$HTML_LAYOUT_FILE")
if [ -z "$HTML_LAYOUT" ]; then
  echo "ERROR: Layout template is empty."
  exit 1
fi

HTML_HEAD_FILE="${4:-templates/head.frag.html}"
if [ ! -f "$HTML_HEAD_FILE" ]; then
  echo "ERROR: Head template '$HTML_HEAD_FILE' does not exist."
  exit 1
fi
HTML_HEAD=$(<"$HTML_HEAD_FILE")
if [ -z "$HTML_HEAD" ]; then
  echo "ERROR: Head template is empty."
  exit 1
fi

HTML_BODY_FILE="${5:-templates/body.frag.html}"
if [ ! -f "$HTML_BODY_FILE" ]; then
  echo "ERROR: Body template '$HTML_BODY_FILE' does not exist."
  exit 1
fi
HTML_BODY=$(<"$HTML_BODY_FILE")
if [ -z "$HTML_BODY" ]; then
  echo "ERROR: Body template is empty."
  exit 1
fi

HTML_FOOTER_FILE="${6:-templates/footer.frag.html}"
if [ ! -f "$HTML_FOOTER_FILE" ]; then
  echo "ERROR: Footer template '$HTML_FOOTER_FILE' does not exist."
  exit 1
fi
HTML_FOOTER=$(<"$HTML_FOOTER_FILE")
if [ -z "$HTML_FOOTER" ]; then
  echo "ERROR: Footer template is empty."
  exit 1
fi

HTML_DIRECTORY_FILE="${7:-templates/directory.frag.html}"
if [ ! -f "$HTML_DIRECTORY_FILE" ]; then
  echo "ERROR: Directory template '$HTML_DIRECTORY_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY=$(<"$HTML_DIRECTORY_FILE")
if [ -z "$HTML_DIRECTORY" ]; then
  echo "ERROR: Directory template is empty."
  exit 1
fi

HTML_DIRECTORY_CRUMB_FILE="${8:-templates/directory-crumb.frag.html}"
if [ ! -f "$HTML_DIRECTORY_CRUMB_FILE" ]; then
  echo "ERROR: Directory crumb template '$HTML_DIRECTORY_CRUMB_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_CRUMB=$(<"$HTML_DIRECTORY_CRUMB_FILE")
if [ -z "$HTML_DIRECTORY_CRUMB" ]; then
  echo "ERROR: Directory crumb template is empty."
  exit 1
fi

HTML_DIRECTORY_ARTICLE_FILE="${9:-templates/listing-article.frag.html}"
if [ ! -f "$HTML_DIRECTORY_ARTICLE_FILE" ]; then
  echo "ERROR: Directory article listing template '$HTML_DIRECTORY_ARTICLE_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_ARTICLE=$(<"$HTML_DIRECTORY_ARTICLE_FILE")
if [ -z "$HTML_DIRECTORY_ARTICLE" ]; then
  echo "ERROR: Directory article listing template is empty."
  exit 1
fi

HTML_DIRECTORY_PINNED_ARTICLE_FILE="${10:-templates/listing-pinned.frag.html}"
if [ ! -f "$HTML_DIRECTORY_PINNED_ARTICLE_FILE" ]; then
  echo "ERROR: Directory pinned article listing template '$HTML_DIRECTORY_PINNED_ARTICLE_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_PINNED_ARTICLE=$(<"$HTML_DIRECTORY_PINNED_ARTICLE_FILE")
if [ -z "$HTML_DIRECTORY_PINNED_ARTICLE" ]; then
  echo "ERROR: Directory pinned article listing template is empty."
  exit 1
fi

HTML_DIRECTORY_FOLDER_FILE="${11:-templates/listing-folder.frag.html}"
if [ ! -f "$HTML_DIRECTORY_FOLDER_FILE" ]; then
  echo "ERROR: Directory folder listing template '$HTML_DIRECTORY_FOLDER_FILE' does not exist."
  exit 1
fi
HTML_DIRECTORY_FOLDER=$(<"$HTML_DIRECTORY_FOLDER_FILE")
if [ -z "$HTML_DIRECTORY_FOLDER" ]; then
  echo "ERROR: Directory folder listing template is empty."
  exit 1
fi

HTML_IFRAME_FILE="${12:-templates/iframe.frag.html}"
if [ ! -f "$HTML_IFRAME_FILE" ]; then
  echo "ERROR: IFrame template '$HTML_IFRAME_FILE' does not exist."
  exit 1
fi
HTML_IFRAME=$(tr -d '\n' < "$HTML_IFRAME_FILE") # Strip Newlines for sed RegEx Replacement
# Substitute {{IFRAME_SRC}} & {{IFRAME_HEIGHT}} in the IFrame HTML Template for the sed RegEx Replacement
HTML_IFRAME="${HTML_IFRAME//\{\{IFRAME_HEIGHT\}\}/\\1}"
HTML_IFRAME="${HTML_IFRAME//\{\{IFRAME_SRC\}\}/\\2}"

HTML_IMG_COMPARISON_FILE="${13:-templates/img-compare.frag.html}"
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

# Purge Build Folder

if [ "$PURGE_BUILD_FOLDER" = true ]; then
  echo "🧹😮‍💨 CLEANUP: Removing build folder '$OUTPUT_DIRECTORY'."
  rm -rf "$OUTPUT_DIRECTORY"
fi

# Build Articles

declare -A article_lut
declare -A article_images
declare -A pinned_articles
declare -A hidden_articles

mkdir -p "$OUTPUT_DIRECTORY"

while read -r filepath; do
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
    read meta_image meta_title < <(
      sed -n -n 's/.*](\([^ ]*\) "\([^"]*\)").*/\1 \2/p' <<< "$first_line"  # Extract the URL & Title Between the )[, ", and "] Character Sequences
    )
    # Extract the Second Non-Empty Line as the Description
    description=$(grep -m 2 '.' "$filepath" | tail -n 1 | cut -c1-160) # tail Gets the Second Non-Empty Line (why would they call it that...)
    # Store Extracted Article Image for Directory Item
    article_images["$output_directory"]="$meta_image"
  else
    meta_image="$DEFAULT_META_IMAGE"
  fi
  # Mark the Article as Hidden if its Original Filename Started with ~
  hidden_articles["$output_directory"]="$hidden"
  # Mark the Article as Pinned if its Original Filename Started with *
  pinned_articles["$output_directory"]="$pinned"

  mkdir -p "$output_directory"

  # Preprocess Embedded iFrames @[height](url)
  preprocessed=$(mktemp ~tmp.XXXXXX.md)
  sed -E "s|@\[([^]]+)\]\(([^)]+)\)|${HTML_IFRAME}|g" "$filepath" > "$preprocessed"

  # Preprocess Embedded Image Comparisons %[alt](url)\n%[alt](url) (Use N; to Match Multiple Lines)
  sed -i "" -E "N;s|%\[([^]]+)\]\(([^)]+)\)\n%\[([^]]+)\]\(([^)]+)\)|${HTML_IMG_COMPARISON}|g" "$preprocessed"

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

  article_lut["$output_directory"]=true
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

    # Determine the Listing Template to Apply
    if [ "${pinned_articles["${subdirectory%/}"]}" = true ]; then
      folder_listing=false
      pinned_listing=true
      default_listing_template="$HTML_DIRECTORY_PINNED_ARTICLE"
      listing_template_path="templates/$directory_relative/listing-pinned.frag.html"
    elif [ "${article_lut["${subdirectory%/}"]}" = true ]; then
      folder_listing=false
      pinned_listing=false
      default_listing_template="$HTML_DIRECTORY_ARTICLE"
      listing_template_path="templates/$directory_relative/listing-article.frag.html"
    else
      folder_listing=true
      pinned_listing=false
      default_listing_template="$HTML_DIRECTORY_FOLDER"
      listing_template_path="templates/$directory_relative/listing-folder.frag.html"
    fi

    if [ -f "$listing_template_path" ]; then
      listing_template=$(<"$listing_template_path")
    else
      listing_template="$default_listing_template"
    fi

    directory_item="${listing_template//\{\{ARTICLE_HREF\}\}/$href}"
    directory_item="${directory_item//\{\{ARTICLE_TITLE\}\}/$slug}"
    directory_item="${directory_item//\{\{ARTICLE_IMAGE\}\}/$article_image}"

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
  directory_template_path="templates/$directory_relative/directory.frag.html"
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
