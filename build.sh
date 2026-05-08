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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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
LLM_OUTPUT=""
SITEMAP_OUTPUT="sitemap.xml"
ROBOTS_OUTPUT="robots.txt"
ARCHIVE_OUTPUT_DIRECTORY="archive"

# — Default Images —
DEFAULT_META_IMAGE="/public/og-image.png"
DEFAULT_ARTICLE_IMAGE=""

# — Development Server —
PORT=3000
EOF

  echo "✍️🤠 CONFIG: $CONFIG_FILE has been created. Edit the config to setup your site."
fi
source "$CONFIG_FILE"

# --- Output directory normalization ---
# OUTPUT_DIRECTORY may be intentionally empty to output into the repo root.
# In that case, we must never accidentally create absolute paths like "/design/..."
OUTPUT_DIRECTORY="${OUTPUT_DIRECTORY:-}"
if [ "$OUTPUT_DIRECTORY" = "." ]; then
  # Treat "." the same as empty for path-joining purposes.
  OUTPUT_DIRECTORY=""
fi

# Public directory (optional config). Used to exclude assets folder(s) from directory index crawling.
PUBLIC_DIRECTORY="${PUBLIC_DIRECTORY:-public}"
SITEMAP_OUTPUT="${SITEMAP_OUTPUT:-sitemap.xml}"
ROBOTS_OUTPUT="${ROBOTS_OUTPUT:-robots.txt}"
ARCHIVE_OUTPUT_DIRECTORY="${ARCHIVE_OUTPUT_DIRECTORY:-archive}"
TWITTER_HANDLE="${TWITTER_HANDLE:-${X_HANDLE:-}}"
X_HANDLE="${X_HANDLE:-$TWITTER_HANDLE}"

site_url_for_path() {
  local path="$1"
  local domain="${DOMAIN%/}"

  path="${path#./}"
  path="${path#/}"
  path="${path%/}"

  if [ -z "$path" ]; then
    printf '%s/' "$domain"
  else
    printf '%s/%s/' "$domain" "$path"
  fi
}

site_file_url_for_path() {
  local path="$1"
  local domain="${DOMAIN%/}"

  path="${path#./}"
  path="${path#/}"

  if [ -z "$path" ]; then
    printf '%s/' "$domain"
  else
    printf '%s/%s' "$domain" "$path"
  fi
}

slugify_path_relative() {
  local path_relative="$1"
  local slug="${path_relative%.md}"

  if [ "$SLUGIFY_ENABLED" = true ]; then
    slug=${slug,,}
    slug=${slug//[^a-z0-9\/]/-}
    slug=$(echo "$slug" | tr -s '-')
    slug=${slug##-}
    slug=${slug%%-}
  fi

  printf '%s' "$slug"
}

html_escape() {
  local value="$1"
  value="${value//&/&amp;}"
  value="${value//</&lt;}"
  value="${value//>/&gt;}"
  value="${value//\"/&quot;}"
  printf '%s' "$value"
}

xml_escape() {
  html_escape "$1"
}

file_lastmod() {
  local file="$1"
  local fallback

  fallback="$(date -u +"%Y-%m-%d")"
  if [ -f "$file" ]; then
    date -u -r "$file" +"%Y-%m-%d" 2>/dev/null || printf '%s' "$fallback"
  else
    printf '%s' "$fallback"
  fi
}

article_description_from_file() {
  local filepath="$1"
  local first_line description

  first_line=$(grep -m 1 '.' "$filepath" || true)
  description="${first_line:0:160}"
  if [ "${first_line:0:2}" = "![" ]; then
    description=$(grep -m 2 '.' "$filepath" | tail -n 1 | cut -c1-160)
  fi

  description="$(printf '%s' "$description" | sed -E 's/^[#>[:space:]]+//; s/\{[^}]*\}//g; s/[][()_*`]//g; s/[[:space:]]+/ /g; s/^[[:space:]]+//; s/[[:space:]]+$//')"
  printf '%s' "$description"
}

build_article_breadcrumbs() {
  local slug="$1"
  local title="$2"
  local parent_path
  local breadcrumbs
  local current_path=""
  local segment label href
  local hidden_style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;"

  parent_path="$(dirname "$slug")"
  breadcrumbs='<nav aria-label="Breadcrumb" style="'"$hidden_style"'"><a href="/" tabindex="-1">Home</a>'

  if [ "$parent_path" != "." ] && [ -n "$parent_path" ]; then
    IFS='/' read -r -a segments <<< "$parent_path"
    for segment in "${segments[@]}"; do
      [ -z "$segment" ] && continue
      if [ -z "$current_path" ]; then
        current_path="$segment"
      else
        current_path="$current_path/$segment"
      fi
      label="$(printf '%s' "${segment//-/ }" | awk '{for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2)} 1')"
      href="/$current_path/"
      breadcrumbs+=' <span aria-hidden="true">/</span> <a href="'"$href"'" tabindex="-1">'"$(html_escape "$label")"'</a>'
    done
  fi

  breadcrumbs+=' <span aria-hidden="true">/</span> <span>'"$(html_escape "$title")"'</span></nav>'
  printf '%s' "$breadcrumbs"
}

build_related_work() {
  local current_slug="$1"
  local current_path_relative="$2"
  local parent_dir candidate candidate_base filename_cleansed candidate_cleansed
  local candidate_path_relative candidate_slug candidate_title candidate_href candidate_description
  local items="" count=0
  local hidden_style="position:absolute;width:1px;height:1px;padding:0;margin:-1px;overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap;border:0;"

  parent_dir="$(dirname "$current_path_relative")"
  [ "$parent_dir" = "." ] && return 0
  [ ! -d "$INPUT_DIRECTORY/$parent_dir" ] && return 0

  while IFS= read -r candidate; do
    [ -z "$candidate" ] && continue
    candidate_base="$(basename "$candidate")"
    [ "${candidate_base:0:1}" = "_" ] && continue
    [ "${candidate_base:0:1}" = "~" ] && continue

    candidate_cleansed="$candidate"
    if [ "${candidate_base:0:1}" = "*" ]; then
      filename_cleansed=$(basename "$candidate_cleansed" | sed 's/^[* ]*//')
      candidate_cleansed="$(dirname "$candidate_cleansed")/$filename_cleansed"
    fi

    candidate_path_relative="${candidate_cleansed#$INPUT_DIRECTORY/}"
    candidate_slug="$(slugify_path_relative "$candidate_path_relative")"
    [ "$candidate_slug" = "$current_slug" ] && continue

    candidate_title=$(basename "${candidate_path_relative%.md}")
    candidate_href="/${candidate_slug}/"
    candidate_description="$(article_description_from_file "$candidate")"

    items+='<li><a href="'"$candidate_href"'" tabindex="-1">'"$(html_escape "$candidate_title")"'</a>'
    if [ -n "$candidate_description" ]; then
      items+='<p>'"$(html_escape "$candidate_description")"'</p>'
    fi
    items+='</li>'

    count=$((count + 1))
    [ "$count" -ge 4 ] && break
  done < <(find "$INPUT_DIRECTORY/$parent_dir" -maxdepth 1 -name "*.md" | sort)

  [ "$count" -eq 0 ] && return 0

  printf '%s' '<section aria-label="Related work" style="'"$hidden_style"'"><h2>Related work</h2><ul>'"$items"'</ul></section>'
}

# Ignore patterns (from .gitignore + optional .ssgignore / ..ssgignore)
declare -a SSG_IGNORE_PATTERNS

load_ignore_patterns_from_file() {
  local file="$1"
  [ ! -f "$file" ] && return 0

  while IFS= read -r raw || [ -n "$raw" ]; do
    # Trim whitespace
    line="$(echo "$raw" | sed -E 's/^[[:space:]]+//; s/[[:space:]]+$//')"
    # Skip blanks/comments
    [ -z "$line" ] && continue
    [[ "$line" == \#* ]] && continue

    # For now we treat patterns as simple globs. Negation is supported via leading "!".
    SSG_IGNORE_PATTERNS+=("$line")
  done < "$file"
}

load_ignore_patterns_from_file "$SCRIPT_DIR/.gitignore"
load_ignore_patterns_from_file "$SCRIPT_DIR/.ssgignore"
load_ignore_patterns_from_file "$SCRIPT_DIR/..ssgignore"

normalize_path_for_ignore_matching() {
  local p="$1"
  p="${p%/}"
  p="${p#./}"
  # If an absolute path under the project root is provided, normalize to project-relative.
  if [[ "$p" == "$SCRIPT_DIR/"* ]]; then
    p="${p#"$SCRIPT_DIR"/}"
  fi
  echo "$p"
}

matches_ignore_pattern() {
  local path="$1"
  local pattern="$2"
  local is_dir="${3:-false}"

  local negated=false
  if [[ "$pattern" == "!"* ]]; then
    negated=true
    pattern="${pattern#!}"
  fi

  # Directory-only patterns (ending with /)
  local dir_only=false
  if [[ "$pattern" == */ ]]; then
    dir_only=true
    pattern="${pattern%/}"
  fi
  if [ "$dir_only" = true ] && [ "$is_dir" != true ]; then
    return 1
  fi

  local anchored=false
  if [[ "$pattern" == /* ]]; then
    anchored=true
    pattern="${pattern#/}"
  fi

  path="$(normalize_path_for_ignore_matching "$path")"

  local matched=false
  if [[ "$pattern" == *"/"* ]]; then
    # Path glob
    if [ "$anchored" = true ]; then
      [[ "$path" == $pattern || "$path" == $pattern/* ]] && matched=true
    else
      [[ "$path" == $pattern || "$path" == $pattern/* || "$path" == */$pattern || "$path" == */$pattern/* ]] && matched=true
    fi
  else
    # Basename glob (matches anywhere)
    base="$(basename "$path")"
    [[ "$base" == $pattern ]] && matched=true
  fi

  if [ "$matched" = true ]; then
    if [ "$negated" = true ]; then
      echo "unignore"
    else
      echo "ignore"
    fi
    return 0
  fi

  return 1
}

should_ignore_by_patterns() {
  local path="$1"
  local is_dir="${2:-false}"
  local decision=""

  local p
  for p in "${SSG_IGNORE_PATTERNS[@]}"; do
    res="$(matches_ignore_pattern "$path" "$p" "$is_dir" || true)"
    if [ -n "$res" ]; then
      decision="$res"
    fi
  done

  [ "$decision" = "ignore" ]
}

# Directory index crawling ignore list:
# - Markdown source directory (articles)
# - Public assets directory
# - Template fragments directory
should_ignore_directory() {
  local dir="${1%/}"
  dir="${dir#./}"

  local input_dir="${INPUT_DIRECTORY%/}"
  input_dir="${input_dir#./}"
  local public_dir="${PUBLIC_DIRECTORY%/}"
  public_dir="${public_dir#./}"
  local template_dir="${TEMPLATE_DIRECTORY%/}"
  template_dir="${template_dir#./}"

  local -a roots=("$input_dir" "$public_dir" "$template_dir")
  local root
  for root in "${roots[@]}"; do
    [ -z "$root" ] && continue

    # Match root or any descendant.
    if [ "$dir" = "$root" ] || [[ "$dir" == "$root/"* ]]; then
      return 0
    fi

    # Also match when these roots appear under OUTPUT_DIRECTORY (if set).
    if [ -n "$OUTPUT_DIRECTORY" ]; then
      if [ "$dir" = "$OUTPUT_DIRECTORY/$root" ] || [[ "$dir" == "$OUTPUT_DIRECTORY/$root/"* ]]; then
        return 0
      fi
    fi
  done

  # Respect ignore files (.gitignore + optional .ssgignore / ..ssgignore)
  if should_ignore_by_patterns "$dir" true; then
    return 0
  fi

  return 1
}

# HTML Template Fragment Filenames
HTML_LAYOUT_FILENAME="layout.frag.html"
HTML_DIRECTORY_LAYOUT_FILENAME="directory.layout.frag.html"
HTML_ARTICLE_LAYOUT_FILENAME="article.layout.frag.html"
HTML_HEAD_FILENAME="head.frag.html"
HTML_BODY_FILENAME="body.frag.html"
HTML_FOOTER_FILENAME="footer.frag.html"
HTML_DIRECTORY_FOOTER_FILENAME="directory.footer.frag.html"
HTML_ARTICLE_FOOTER_FILENAME="article.footer.frag.html"
HTML_DIRECTORY_FILENAME="directory.frag.html"
HTML_DIRECTORY_CRUMB_FILENAME="directory-crumb.frag.html"
HTML_DIRECTORY_ARTICLE_FILENAME="listing-article.frag.html"
HTML_DIRECTORY_PINNED_ARTICLE_FILENAME="listing-pinned.frag.html"
HTML_DIRECTORY_FOLDER_FILENAME="listing-folder.frag.html"
HTML_DOWNLOAD_LINK_FILENAME="download-link.frag.html"
HTML_EMAIL_LINK_FILENAME="email-link.frag.html"
HTML_SOCIAL_LINK_FILENAME="social-link.frag.html"
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

read_scoped_template() {
  local relative_path="$1"
  local filename="$2"
  local default_template="$3"
  local template_root="${TEMPLATE_DIRECTORY%/}"
  local current="${relative_path%/}"

  current="${current#./}"
  if [ "$current" = "." ]; then
    current=""
  fi

  while [ -n "$current" ] && [ "$current" != "/" ]; do
    local candidate="$template_root/$current/$filename"
    if [ -f "$candidate" ]; then
      cat "$candidate"
      return 0
    fi

    local parent
    parent="$(dirname "$current")"
    if [ "$parent" = "$current" ] || [ "$parent" = "." ]; then
      break
    fi
    current="$parent"
  done

  printf '%s' "$default_template"
}

read_page_footer_template() {
  local relative_path="$1"
  local scoped_footer_filename="$2"
  local fallback_template

  fallback_template="$(read_scoped_template "$relative_path" "$HTML_FOOTER_FILENAME" "$HTML_FOOTER")"
  read_scoped_template "$relative_path" "$scoped_footer_filename" "$fallback_template"
}

read_page_layout_template() {
  local relative_path="$1"
  local scoped_layout_filename="$2"
  local fallback_template

  fallback_template="$(read_scoped_template "$relative_path" "$HTML_LAYOUT_FILENAME" "$HTML_LAYOUT")"
  read_scoped_template "$relative_path" "$scoped_layout_filename" "$fallback_template"
}

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

HTML_SOCIAL_LINK_FILE="${TEMPLATE_DIRECTORY}/${HTML_SOCIAL_LINK_FILENAME}"
if [ ! -f "$HTML_SOCIAL_LINK_FILE" ]; then
  echo "ERROR: Social link template '$HTML_SOCIAL_LINK_FILE' does not exist."
  exit 1
fi
HTML_SOCIAL_LINK=$(<"$HTML_SOCIAL_LINK_FILE")
if [ -z "$HTML_SOCIAL_LINK" ]; then
  echo "ERROR: Social link template is empty."
  exit 1
fi
HTML_SOCIAL_LINK=$(tr -d '\n' < "$HTML_SOCIAL_LINK_FILE") # Strip Newlines for sed RegEx Replacement
HTML_SOCIAL_LINK="${HTML_SOCIAL_LINK//&/\\&}" # Escape All & Ampersands for sed RegEx Replacement
# Substitute {{SOCIAL_LINK_ICON_SRC}}, {{SOCIAL_LINK_SRC}}, & {{SOCIAL_LINK_TITLE}} in the Social Link HTML Template for the sed RegEx Replacement
HTML_SOCIAL_LINK="${HTML_SOCIAL_LINK//\{\{SOCIAL_LINK_ICON_SRC\}\}/\\1}"
HTML_SOCIAL_LINK="${HTML_SOCIAL_LINK//\{\{SOCIAL_LINK_SRC\}\}/\\2}"
HTML_SOCIAL_LINK="${HTML_SOCIAL_LINK//\{\{SOCIAL_LINK_TITLE\}\}/\\3}"

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
rm -f "./~tmp."* 2>/dev/null || true

# Purge Build Folder

if [ "$PURGE_BUILD_FOLDER" = true ]; then
  if [ -n "$OUTPUT_DIRECTORY" ]; then
    echo "🧹😮‍💨 CLEANUP: Removing build folder '$OUTPUT_DIRECTORY'."
    rm -rf "$OUTPUT_DIRECTORY"
  else
    echo "🧹😮‍💨 CLEANUP: OUTPUT_DIRECTORY is empty; skipping purge to avoid deleting the project root."
  fi
fi

# Build Articles

declare -A article_lut
declare -A article_images
declare -A article_descriptions
declare -A pinned_articles
declare -A hidden_articles
declare -A generated_directories
declare -a sitemap_entries
declare -a archive_entries

add_sitemap_url() {
  local loc="$1"
  local lastmod="$2"
  local changefreq="${3:-monthly}"
  local priority="${4:-0.5}"

  sitemap_entries+=("$loc|$lastmod|$changefreq|$priority")
}

add_archive_entry() {
  local section="$1"
  local href="$2"
  local title="$3"
  local description="$4"

  archive_entries+=("$section|$href|$title|$description")
}

add_sitemap_url "$(site_url_for_path "${OUTPUT_DIRECTORY}")" "$(date -u +"%Y-%m-%d")" "weekly" "1.0"
add_archive_entry "pages" "/" "Home" "Alfred R. Duarte portfolio homepage."

if [ -n "$OUTPUT_DIRECTORY" ]; then
  mkdir -p "$OUTPUT_DIRECTORY"
fi

if [ -n "$LLM_OUTPUT" ]; then
  llm_out_path="${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$LLM_OUTPUT"
  mkdir -p "$(dirname "$llm_out_path")"
  : > "$llm_out_path"
fi

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

  # Add the Article to the llm.txt Output File
  if [ -n "$LLM_OUTPUT" ] && [ "$hidden" = false ]; then
    llm_out_path="${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$LLM_OUTPUT"
    {
      printf "~~~\n\nllm.txt\n\nAuthor: $AUTHOR\nDomain: $DOMAIN\n\n~~~\n\n"
      cat "$filepath"
      printf "\n~~~\n\nThe above material is owned by the author.\n\nThis file was generated with SASHA.\n\n~~~\n"
    } >> "$llm_out_path"
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
  slug="$(slugify_path_relative "$path_relative")"
  title=$(basename "${path_relative%.md}")
  output_directory="${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}${slug}"
  output_path="$output_directory/index.html"
  page_title="$title$PAGE_TITLE_SUFFIX"
  url="$(site_url_for_path "${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$slug")"
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
  if [ "$hidden" = false ]; then
    article_section="$(dirname "$slug")"
    article_section="${article_section%%/*}"
    if [ "$article_section" = "." ]; then
      article_section="pages"
    fi
    add_sitemap_url "$url" "$(file_lastmod "$filepath")" "monthly" "0.8"
    add_archive_entry "$article_section" "/${slug}/" "$title" "$(article_description_from_file "$filepath")"
  fi

  mkdir -p "$output_directory"

  # Create a Temporary File for Preprocessing
  tmp_base="${TMPDIR%/}"
  tmp_base="${tmp_base:-/tmp}"
  preprocessed_raw="$(mktemp "${tmp_base}/ssg-preprocess.XXXXXX")"
  preprocessed="${preprocessed_raw}.md"
  mv -f "$preprocessed_raw" "$preprocessed"
  if [ -z "$preprocessed" ] || [ ! -f "$preprocessed" ]; then
    echo "ERROR: mktemp failed while preprocessing '$filepath'."
    exit 1
  fi

  # Preprocess Embedded iFrames @[height](url)
  sed -E "s|@\[([^]]+)\]\(([^)]+)\)|${HTML_IFRAME}|g" "$filepath" > "$preprocessed"

  # Preprocess Download Links +[alt](url "title")
  sed -i "" -E 's|\+\[([^]]+)\]\(([^ ]+) "([^"]+)"\)|'"$HTML_DOWNLOAD_LINK"'|g' "$preprocessed"

  # Preprocess Email Links [alt](mailto:url "title")
  sed -i "" -E 's|\[([^]]+)\]\(mailto:([^ ]+) "([^"]+)"\)|'"$HTML_EMAIL_LINK"'|g' "$preprocessed"

  # Preprocess Social Links >[icon link](url "title")
  sed -i "" -E 's|>\[([^]]+)\]\(([^ ]+) "([^"]+)"\)|'"$HTML_SOCIAL_LINK"'|g' "$preprocessed"

  # Preprocess Embedded Image Comparisons %[alt](url)\n%[alt](url) (Use N; to Match Multiple Lines)
  sed -i "" -E "N;s|%\[([^]]+)\]\(([^)]+)\)\n%\[([^]]+)\]\(([^)]+)\)|${HTML_IMG_COMPARISON}|g" "$preprocessed"

  # Preprocess Embedded Videos ~[attributes](url "type")
  sed -i "" -E "s|~\[([^]]+)\]\(([^)]+) \"([^)]+)\"\)|$HTML_VIDEO|g" "$preprocessed"

  # Process the Markdown Article
  body=$(pandoc "$preprocessed")
  rm "$preprocessed"

  layout_template="$(read_page_layout_template "$slug" "$HTML_ARTICLE_LAYOUT_FILENAME")"

  # Replace {{HEAD}} in the Layout HTML Template with the Contents of the Head HTML Template
  layout=$(echo "${layout_template//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML Template with the Contents of the Body HTML Template
  layout="${layout//\{\{BODY\}\}/$HTML_BODY}"
  # Replace {{FOOTER}} in the Layout HTML Template with the Contents of the Footer HTML Template
  footer_template="$(read_page_footer_template "$slug" "$HTML_ARTICLE_FOOTER_FILENAME")"
  layout="${layout//\{\{FOOTER\}\}/$footer_template}"

  layout="${layout//\{\{PAGE_TITLE\}\}/$page_title}"
  layout="${layout//\{\{TITLE\}\}/$title}"
  layout="${layout//\{\{AUTHOR\}\}/$AUTHOR}"
  layout="${layout//\{\{X_HANDLE\}\}/$X_HANDLE}"
  layout="${layout//\{\{TWITTER_HANDLE\}\}/$TWITTER_HANDLE}"
  layout="${layout//\{\{DESCRIPTION\}\}/$description}"
  layout="${layout//\{\{MARKDOWN\}\}/"$body"}"
  article_breadcrumbs="$(build_article_breadcrumbs "$slug" "$title")"
  related_work="$(build_related_work "$slug" "$path_relative")"
  layout="${layout//\{\{ARTICLE_BREADCRUMBS\}\}/"$article_breadcrumbs"}"
  layout="${layout//\{\{RELATED_WORK\}\}/"$related_work"}"
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
  # Track generated directories so directory index generation doesn't walk the entire repo.
  dir="$output_directory"
  while [ -n "$dir" ] && [ "$dir" != "." ] && [ "$dir" != "/" ]; do
    generated_directories["$dir"]=true
    parent="$(dirname "$dir")"
    if [ "$parent" = "$dir" ]; then
      break
    fi
    dir="$parent"
  done
  echo "🔨🤠 GENERATED: $output_path"
done < <(find "$INPUT_DIRECTORY" -name "*.md")

# Build Directory Indexes

directories_to_index="$(printf "%s\n" "${!generated_directories[@]}" | sort)"
while IFS= read -r directory; do
  [ -z "$directory" ] && continue
  if should_ignore_directory "$directory"; then
    continue
  fi

  # Determine Articles by Counting Subfolders Within a Directory (Articles Only Contain a Single index.html)
  if [ -f "$directory/index.html" ]; then
    folder_count=$(find "$directory" -mindepth 1 -maxdepth 1 -type d | wc -l)
    if [ "$folder_count" -eq 0 ]; then
      continue
    fi
  fi  

  if [ -n "$OUTPUT_DIRECTORY" ]; then
    directory_relative="${directory#$OUTPUT_DIRECTORY/}"
  else
    directory_relative="$directory"
  fi
  directory_relative="${directory_relative#./}"
  page_title="${directory_relative}${PAGE_TITLE_SUFFIX}"
  url="$(site_url_for_path "${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$directory_relative")"

  folder_links=""
  article_links=""
  pinned_article_links=""
  hidden_article_links=""
  for subdirectory in "$directory"/*/; do
    [ ! -d "$subdirectory" ] && continue # Skip Empty Directories

    slug=$(basename "$subdirectory")
    if should_ignore_directory "$subdirectory"; then
      continue
    fi
    subdirectory_relative="$subdirectory"
    if [ -n "$OUTPUT_DIRECTORY" ]; then
      subdirectory_relative="${subdirectory#$OUTPUT_DIRECTORY/}"
    fi
    subdirectory_relative="${subdirectory_relative#./}"
    href="/${subdirectory_relative%/}/"

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
  parent_rel="$(dirname "$directory_relative")"
  if [ "$parent_rel" = "." ]; then
    parent_directory_href="/"
  else
    parent_directory_href="/$parent_rel/"
  fi
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

  layout_template="$(read_page_layout_template "$directory_relative" "$HTML_DIRECTORY_LAYOUT_FILENAME")"

  # Replace {{HEAD}} in the Layout HTML Template with the Contents of the Head HTML Template
  layout=$(echo "${layout_template//\{\{HEAD\}\}/$HTML_HEAD}")
  # Replace {{BODY}} in the Layout HTML Template with the Contents of the Populated Directory HTML Template
  layout="${layout//\{\{BODY\}\}/$body}"
  # Replace {{FOOTER}} in the Layout HTML Template with the Contents of the Footer HTML Template
  footer_template="$(read_page_footer_template "$directory_relative" "$HTML_DIRECTORY_FOOTER_FILENAME")"
  layout="${layout//\{\{FOOTER\}\}/$footer_template}"

  layout="${layout//\{\{PAGE_TITLE\}\}/$page_title}"
  layout="${layout//\{\{AUTHOR\}\}/$AUTHOR}"
  layout="${layout//\{\{X_HANDLE\}\}/$X_HANDLE}"
  layout="${layout//\{\{TWITTER_HANDLE\}\}/$TWITTER_HANDLE}"
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

  add_sitemap_url "$url" "$(date -u +"%Y-%m-%d")" "weekly" "0.6"

  echo "🔨🤠 GENERATED DIRECTORY: $output_path"
done <<< "$directories_to_index"

# Build HTML Archive

archive_item_list_for_section() {
  local target_section="$1"
  local entry section href title description
  local items=""

  for entry in "${archive_entries[@]}"; do
    IFS='|' read -r section href title description <<< "$entry"
    [ "$section" != "$target_section" ] && continue

    items+='<li class="border-t border-neutral-200 py-3"><a href="'"$(html_escape "$href")"'" class="font-medium text-neutral-800 hover:underline">'"$(html_escape "$title")"'</a>'
    if [ -n "$description" ]; then
      items+='<p class="mt-1 text-xs leading-5 text-neutral-500">'"$(html_escape "$description")"'</p>'
    fi
    items+='</li>'
  done

  printf '%s' "$items"
}

archive_section_heading() {
  local section="$1"

  case "$section" in
    pages)
      printf 'Pages'
      ;;
    *)
      printf '%s' "${section//-/ }" | awk '{for (i = 1; i <= NF; i++) $i = toupper(substr($i, 1, 1)) substr($i, 2)} 1'
      ;;
  esac
}

archive_section_markup() {
  local section="$1"
  local heading items

  heading="$(archive_section_heading "$section")"
  items="$(archive_item_list_for_section "$section")"
  [ -z "$items" ] && return 0

  printf '%s' '<section class="mt-8"><h2 class="text-sm font-medium text-neutral-800">'"$(html_escape "$heading")"'</h2><ul class="mt-2 grid gap-x-6 md:grid-cols-2">'"$items"'</ul></section>'
}

archive_sections=""
declare -A archive_sections_seen
for archive_section in pages design engineering; do
  archive_sections+="$(archive_section_markup "$archive_section")"
  archive_sections_seen["$archive_section"]=true
done
for archive_entry in "${archive_entries[@]}"; do
  IFS='|' read -r archive_section archive_href archive_title archive_description <<< "$archive_entry"
  [ -n "${archive_sections_seen["$archive_section"]}" ] && continue
  archive_sections+="$(archive_section_markup "$archive_section")"
  archive_sections_seen["$archive_section"]=true
done

archive_body='<header><h1 class="mt-2 text-sm font-medium">Archive</h1></header><main class="w-full max-w-[980px] m-auto mt-6 md:mt-auto p-[15px] md:p-[45px]"><p class="text-sm leading-6 text-neutral-500">A crawlable index of public portfolio pages and case studies.</p><section class="mt-8"><h2 class="text-sm font-medium text-neutral-800">Sections</h2><ul class="mt-2 grid gap-x-6 md:grid-cols-2"><li class="border-t border-neutral-200 py-3"><a href="/design/" class="font-medium text-neutral-800 hover:underline">Design</a></li><li class="border-t border-neutral-200 py-3"><a href="/engineering/" class="font-medium text-neutral-800 hover:underline">Engineering</a></li></ul></section>'"$archive_sections"'</main>'
archive_directory="${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}${ARCHIVE_OUTPUT_DIRECTORY}"
archive_output_path="$archive_directory/index.html"
archive_url="$(site_url_for_path "${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$ARCHIVE_OUTPUT_DIRECTORY")"

mkdir -p "$archive_directory"

layout="${HTML_LAYOUT//\{\{HEAD\}\}/$HTML_HEAD}"
layout="${layout//\{\{BODY\}\}/"$archive_body"}"
layout="${layout//\{\{FOOTER\}\}/$HTML_FOOTER}"
layout="${layout//\{\{PAGE_TITLE\}\}/Archive$PAGE_TITLE_SUFFIX}"
layout="${layout//\{\{TITLE\}\}/Archive}"
layout="${layout//\{\{AUTHOR\}\}/$AUTHOR}"
layout="${layout//\{\{X_HANDLE\}\}/$X_HANDLE}"
layout="${layout//\{\{TWITTER_HANDLE\}\}/$TWITTER_HANDLE}"
layout="${layout//\{\{DESCRIPTION\}\}/Crawlable index of public portfolio pages and case studies.}"
layout="${layout//\{\{URL\}\}/$archive_url}"
layout="${layout//\{\{YEAR\}\}/$(date +%Y)}"
layout="${layout//\{\{IMAGE\}\}/$DOMAIN$DEFAULT_META_IMAGE}"

echo "$layout" > "$archive_output_path"
if [ "$PRETTIER_ENABLED" = true ]; then
  prettier --write "$archive_output_path"
fi
add_sitemap_url "$archive_url" "$(date -u +"%Y-%m-%d")" "weekly" "0.7"
echo "🔨🤠 GENERATED ARCHIVE: $archive_output_path"

# Build robots.txt and sitemap.xml

sitemap_path="${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$SITEMAP_OUTPUT"
robots_path="${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$ROBOTS_OUTPUT"
sitemap_url="$(site_file_url_for_path "${OUTPUT_DIRECTORY:+$OUTPUT_DIRECTORY/}$SITEMAP_OUTPUT")"

mkdir -p "$(dirname "$sitemap_path")"
{
  printf '<?xml version="1.0" encoding="UTF-8"?>\n'
  printf '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'
  for sitemap_entry in "${sitemap_entries[@]}"; do
    IFS='|' read -r sitemap_loc sitemap_lastmod sitemap_changefreq sitemap_priority <<< "$sitemap_entry"
    printf '  <url>\n'
    printf '    <loc>%s</loc>\n' "$(xml_escape "$sitemap_loc")"
    printf '    <lastmod>%s</lastmod>\n' "$(xml_escape "$sitemap_lastmod")"
    printf '    <changefreq>%s</changefreq>\n' "$(xml_escape "$sitemap_changefreq")"
    printf '    <priority>%s</priority>\n' "$(xml_escape "$sitemap_priority")"
    printf '  </url>\n'
  done
  printf '</urlset>\n'
} > "$sitemap_path"
echo "🔨🤠 GENERATED SITEMAP: $sitemap_path"

mkdir -p "$(dirname "$robots_path")"
{
  printf 'User-agent: *\n'
  printf 'Allow: /\n\n'
  printf 'Sitemap: %s\n' "$sitemap_url"
} > "$robots_path"
echo "🔨🤠 GENERATED ROBOTS: $robots_path"
