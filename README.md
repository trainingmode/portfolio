# `Sasha` — Static Site Generator

> _`Sasha` is a lightweight static site generator built on [Pandoc](https://pandoc.org/ "Pandoc — a universal document converter")._

`Sasha` converts your folder of **`.md` Markdown** files into a static site.

It ships with a simple **templating system** based on the **`{{ }}` Mustache** syntax. Templates are **HTML** fragments, with no other requirements.

Generated sites are as lightweight as you make them. Sites can easily be deployed to nearly any service—like [GitHub Pages](https://pages.github.com/ "GitHub Pages")—for free or low-cost.

Built on the **`Directory`** → **`Article`** folder structure concept. Similar to other Static Site Generators like [Jekyll](https://jekyllrb.com/ "Jekyll • Simple, blog-aware, static sites | Transform your plain text into static websites and blogs") or [Gatsby](https://www.gatsbyjs.com/ "The Best React-Based Framework | Gatsby").

1. [**Installation**](#installation)
2. [**Usage**](#usage)
3. [**Basic Concepts**](#basic-concepts)
4. [**Folder Structure**](#folder-structure)
5. [**Formatting Articles**](#formatting-articles)
6. [**Templates**](#templates)
7. [**Deployment**](#deployment)

## Requirements

#### **_Services_**

- [Node.js](https://nodejs.org/en/ "Node.js — JavaScript runtime") (chokidar, serve) — +**19**
  > _Note: Node.js is **not** required for the builder._

#### **_Builder_**

- [Bash](https://www.gnu.org/software/bash/manual/bash.html "Bash Reference Manual") — +**4**
- [Pandoc](https://pandoc.org/ "Pandoc — a universal document converter") — +**3**
- [Prettier](https://prettier.io/ "Prettier — The opinionated code formatter") (_Optional_) — +**3**

#### **_Development Server_**

- [Serve](https://github.com/vercel/serve "vercel/serve: Static file serving and directory listing") (_Optional_) — +**14**
- [Python](https://www.python.org/ "Python") (_Required, unless using Serve_) — +**3**

#### **_CLI_**

- [Chokidar CLI](https://www.npmjs.com/package/chokidar-cli "chokidar-cli: npm") — +**9.5**

# Installation

1. Install the required dependencies.

   > _The following instructions are for **macOS** using [Homebrew](https://brew.sh/ "Homebrew — The Missing Package Manager for macOS (or Linux)")._

   **CLI dependencies:**

   ```sh
   brew install bash node pandoc python3
   ```

   **Node services:**

   ```sh
   npm install -g chokidar-cli prettier serve
   ```

2. Install the `Sasha` CLI into your working directory.

   - **`build.sh`** — Static site builder.
   - **`serve.sh`** — Local development server.
   - **`ssg.sh`** — `Sasha` CLI.

3. Mark the CLI scripts as executable.

   ```sh
   chmod +x build.sh server.sh ssg.sh
   ```

### Windows

**Windows** is not officially supported.

To use `Sasha` on **Windows**:

- Install the required dependencies.
- Set the appropriate location for `bash` at the top of the CLI scripts.
- Mark the CLI scripts as executable.

# Configuration

The `Sasha` CLI is configured using a `ssg.config` file.

If no `ssg.config` file is found, a default one will be created in the current directory.

The easiest way to configure `Sasha` is to edit the default `ssg.config` file. It will be created for you in the root of your project when you first run `Sasha` in a new project.

### **`DOMAIN`**

The domain of your site.

### **`PAGE_TITLE_SUFFIX`**

The suffix appended to the title of each page.

_Example:_

`Welcome.md`

```sh
PAGE_TITLE_SUFFIX=" | SASHA | Static Site Generator"
```

```
Welcome | SASHA | Static Site Generator
```

### **`AUTHOR`**

The author of the site, used in meta tags.

### **`X_HANDLE`**

The X/Twitter handle of the author, used in meta tags.

### **`PRETTIER_ENABLED`**

Enables formatting via Prettier for the generated HTML.

### **`PURGE_BUILD_FOLDER`**

Purges the entire output directory before building the site.

### **`SLUGIFY_ENABLED`**

Enables slugification of the file names of the articles.

_Example:_

`Welcome! Here's My New Site.md`

```
`welcome-here-s-my-new-site`
```

### **`DEFAULT_META_IMAGE`**

The default image used for the meta tags in the generated site header, if no header image is found in the article.

This is the image displayed when the page is shared, such as on social media.

### **`DEFAULT_ARTICLE_IMAGE`**

The default image used for the article thumbnail in **`Directory`** pages, if no header image is found in the article.

If empty, no default article thumbnail is displayed.

### **`PORT`**

The port the development server will run on.

# Usage

The `Sasha` CLI is used to build & serve your site.

It watches the current directory, and automatically rebuilds your site whenever you make changes to your project.

```sh
./ssg.sh [config_file] [input_directory] [output_directory] [template_directory] [ignore_file]
```

- **`[config_file]`**

  _Default: `ssg.config`_

  The `Sasha` configuration file.

  See [Configuration](#configuration) for a guide to setting up your config file.

- **`[input_directory]`**

  _Default: `markdown`_

  The directory containing your **Markdown** articles.

- **`[output_directory]`**

  _Default: `portfolio`_

  The directory where your generated site will be saved.

- **`[template_directory]`**

  _Default: `templates`_

  The directory containing your HTML template fragments.

- **`[ignore_file]`** (_Optional_)

  _Default: `.ssgignore`_

  The ignore file containing the list of files ignored by the watcher.

  _Example:_

  ```sh
  .DS_Store
  .gitignore
  .nojekyll
  CNAME
  ```

## Builder CLI

The `Sasha` Builder can be run manually to build your site.

```sh
./build.sh [config_file] [input_directory] [output_directory] [template_directory]
```

- **`[config_file]`**

  _Default: `ssg.config`_

  The `Sasha` configuration file.

  See [Configuration](#configuration) for a guide to setting up your config file.

- **`[input_directory]`**

  _Default: `markdown`_

  The directory containing your **Markdown** articles.

- **`[output_directory]`**

  _Default: `portfolio`_

  The directory where your generated site will be saved.

- **`[template_directory]`**

  _Default: `templates`_

  The directory containing your HTML template fragments.

## Development Server CLI

The development server can be run independently to only serve your site.

```sh
./server.sh [port]
```

- **`[port]`**

  _Default: `3000`_

  The port the development server will run on.

# Basic Concepts

`Sasha` is purposefully simple.

Articles & directories are rendered into templates.

## Articles & Directories

An **`Article`** is a **`.md` Markdown** formatted text file.

A **`Directory`** is a folder containing **`Article`** files, or other **`Directory`** folders.

Both **`Article`** files & **`Directory`** folders are rendered as pages in your site.

**`Directory`** pages display **`Article`** files and other **`Directory`** subfolders.

An **`Article`** page displays the content of its associated **`.md` Markdown** file.

## Templates

A **`Template`** is a **`.frag.html` HTML** fragment.

**`{{ }}` Tags** are used to insert content & other HTML fragments into a **`Template`**.

# Folder Structure

`Sasha` uses your **`Article`** folder structure to generate your site structure.

## Input Folder

There are no restrictions on the structure of your **`Article`** folder provided to the CLI.

The structure of your generated site will mirror the structure of your **`Article`** folder.

## Templates Folder

Your folder of **`Template`** fragments will contain default templates applied across your site.

You can override templates by mirroring the folder structure of your **`Article`** files.

For example, to override the `design` **`Directory`** page template:

```sh
├── markdown
│   └── design
│       ├── README.md
│       └── SASHA.md
└── templates
    ├── design
    │   └── directory.frag.html
    │ ...
```

## Example Structure

```sh
├── markdown
│   ├── design
│   │   ├── Render–Optimized Skeumorphic UI, 2022.md
│   │   └── Website Redesign, 2023.md
│   └── engineering
│       ├── Static Site Generator.md
│       └── OpenGL 2.1 Pipeline Framework.md
└── templates
    ├── design
    │   └── directory.frag.html
    ├── head.frag.html
    ├── body.frag.html
    ├── directory.frag.html
    ├── layout.frag.html
    └── footer.frag.html
```

# Formatting Articles

Articles are formatted using **Markdown**, and rendered using **Pandoc**.

Technically, **_any_** markup language supported by **Pandoc** can be used. **Markdown** is currently the only format supported & verified working with `Sasha`.

Articles contain additional formatting features to extend functionality & enhance presentation.

## Article Listing Title

The title of an **`Article`** is the filename of the file, without the file extension.

It will be displayed as the title of the article listing on **`Directory`** pages.

_Example:_

`Case Study: Light & Shadows, 2025.md`

```
Case Study: Light & Shadows, 2025
```

## Article Header Image

The header image of an **`Article`** is the first `![alt](link "title")` image in the article.

It will be displayed as the thumbnail for the **`Article`** listing on **`Directory`** pages, as well as for meta tags when sharing the article.

## Article Description

The description of an **`Article`** is the first paragraph matched, following the [Article Header Image](#article-header-image).

It will be displayed as the description for the **`Article`** listing on **`Directory`** pages, as well as for meta tags when sharing the article.

## Article Category/Tags

You can add a category to an **`Article`** by adding a `>` **Blockquote** to the line directly before the article's first `#` **Heading**.

_Example:_

```
> Case Study
# Light & Shadows
```

## Article Components

`Sasha` supports a few components using special **Markdown** syntax.

### `+[alt](url "title")` **Download Link**

Links can be embedded as downloadable links directly inside articles using a link and display lablel.

The `download-link.frag.html` **Download Link Component HTML Template** is used to render the parsed download link.

_Example:_

```
+[View My Resume](/public/resume.pdf "Download Alfred R. Duarte's Resume")
```

### `[alt](mailto:link "title")` **Email Link**

Emails can be automatically transformed into a component.

If no `email-link.frag.html` **Email Link Component HTML Template** is found, the email will be displayed as a normal link.

_Example:_

```
[Email Me](mailto:alfred.r.duarte@gmail.com "Email Alfred R. Duarte")
```

### `@[size](link)` **iFrame**

iFrames can be embedded directly inside articles using a link and a display size.

The `iframe.frag.html` **iFrame Component HTML Template** is used to render the parsed iFrame.

_Example:_

```
@[100%](https://www.wikipedia.org/)
```

### `%[alt](link)` **Image Comparison**

Up to `2` images can be compared in a single container using the `%[alt](link)` syntax.

Images are separated by a single line break.

The `img-compare.frag.html` **Image Comparison Component HTML Template** is used to render the parsed image comparison.

_Example:_

```
%[Before](/image1.png)
%[After](/image2.png)
```

### `~[attributes](link "type")` **Video**

Videos can be embedded directly inside articles using a link, video attributes, and a media type.

The `video.frag.html` **Video Component HTML Template** is used to render the parsed video.

_Example:_

```
~[autoplay muted loop playsinline width="1080"](/video.mp4 "video/mp4")
```

## Article Listing Special Symbols

You can prefix special symbols to the start of the filename of an **`Article`** to change its rendering behavior.

- `*` **Pinned**

  Place the article in the list of pinned articles.

  Pinned articles are rendered in a separate list than regular articles.

- `~` **Hidden**

  Hide the article from the **`Directory`** page.

  The article will still be rendered as a page and can be linked to directly.

- `_` **Not Rendered**

  The article will not be rendered. It will not be present in your site.

_Example:_

```
- Pinned Article.md
~ Hidden Article.md
_ Not Rendered.md
```

# Templates

Templates are **`.frag.html` HTML** fragments, with no other requirements.

Templates can contain **`{{ }}` replacement tags**. These tags are replaced when an **`Article`** is rendered.

Both **`Article`** & **`Directory`** pages are rendered into the **`layout.frag.html`** template.

**_[Layout](#layout-templates):_**

- [`layout.frag.html`](#layoutfraghtml)
- [`head.frag.html`](#headfraghtml)
- [`footer.frag.html`](#footerfraghtml)

**_[Article](#article-templates):_**

- [`body.frag.html`](#bodyfraghtml)
- [`download-link.frag.html`](#downloadlinkfraghtml)
- [`email-link.frag.html`](#emaillinkfraghtml)
- [`iframe.frag.html`](#iframefraghtml)
- [`img-compare.frag.html`](#imgcomparefraghtml)
- [`video.frag.html`](#videofraghtml)

**_[Directory](#directory-templates):_**

- [`directory.frag.html`](#directoryfraghtml)
- [`directory-crumb.frag.html`](#directorycrumbfraghtml)
- [`listing-article.frag.html`](#listingarticlefraghtml)
- [`listing-pinned.frag.html`](#listingpinnedfraghtml)
- [`listing-folder.frag.html`](#listingfolderfraghtml)

## Layout Templates

Layout templates are used to render both **`Article`** & **`Directory`** pages.

Some `{{ }}` tags can be used across all fragments injected into the main layout template.

Select **replacement tags** are included with each template description below.

### `layout.frag.html`

The layout template is the main template that all other fragments are rendered into.

- `{{ HEAD }}`

  The contents of the **`head.frag.html` Head Template**.

- `{{ BODY }}`

  The contents of the template rendered for the page.

  For **`Article`** pages, the **`body.frag.html` Body Template** is used to render the contents.

  For **`Directory`** pages, the **`directory.frag.html` Directory Template** is used to render the contents.

- `{{ FOOTER }}`

  The contents of the **`footer.frag.html` Footer Template**.

### `head.frag.html`

The head template is used to render the page `<head>`.

This includes the `<title>` tag & `<meta>` tags.

- `{{ PAGE_TITLE }}`

  The title of the page.

  Constructed from page title and the `PAGE_TITLE_SUFFIX` in the `ssg.config` file.

  For **`Article`** pages, the filename of the article is used as the page title.

  For **`Directory`** pages, the name of the folder is used as the page title.

- `{{ DESCRIPTION }}`

  The description of the page.

- `{{ AUTHOR }}`

  The author of the site.

  Extracted from the `ssg.config` file.

- `{{ URL }}`

  The canonical URL of the page.

  Constructed from the path to the **`Article`**/**`Directory`** and the `DOMAIN` from the `ssg.config` file.

- `{{ IMAGE }}`

  The URL of the header image of the article.

  If no header image is found, the `DEFAULT_ARTICLE_IMAGE` from the `ssg.config` file is used.

- `{{ TWITTER_HANDLE }}`

  The X/Twitter handle of the author.

  Extracted from the `ssg.config` file.

### `footer.frag.html`

The footer template is used to render the page `<footer>`.

- `{{ YEAR }}`

  The current year.

## Article Templates

### `body.frag.html`

The body template is used to render the **`Article`** contents into the page `<body>`.

- `{{ TITLE }}`

  The title of the article.

  Extracted from the article filename.

- `{{ MARKDOWN }}`

  The content of the **`.md` Markdown** article rendered as HTML.

### `download-link.frag.html`

The download link template is used to render the **`+[alt](url "title")` Download Link** component.

- `{{ DOWNLOAD_LINK_ALT }}`

  The display label for the download link.

- `{{ DOWNLOAD_LINK_SRC }}`

  The `src` attribute of the download link.

- `{{ DOWNLOAD_LINK_TITLE }}`

  The `title` attribute of the download link.

  This is used for the text displayed when hovering over the link.

### `email-link.frag.html`

The email link template is used to render the **`[alt](mailto:link "title")` Email Link** component.

- `{{ EMAIL_LINK_ALT }}`

  The display label for the email link.

- `{{ EMAIL_LINK_SRC }}`

  The `src` attribute of the email link.

  This does **not** include the `mailto:` prefix.

- `{{ EMAIL_LINK_TITLE }}`

  The `title` attribute of the email link.

### `iframe.frag.html`

The iFrame template is used to render the **`@[size](link)` iFrame** component.

- `{{ IFRAME_HEIGHT }}`

  The height of the iFrame.

- `{{ IFRAME_SRC }}`

  The `src` attribute of the iFrame.

### `img-compare.frag.html`

The image comparison template is used to render the **`%[alt](link)` Image Comparison** component.

- `{{ IMG_COMPARE_ALT1 }}`

  The `alt` attribute for the first image in the comparison.

- `{{ IMG_COMPARE_SRC1 }}`

  The `src` attribute for the first image in the comparison.

- `{{ IMG_COMPARE_ALT2 }}`

  The `alt` attribute for the second image in the comparison.

- `{{ IMG_COMPARE_SRC2 }}`

  The `src` attribute for the second image in the comparison.

### `video.frag.html`

The video template is used to render the **`~[attributes](link "type")` Video** component.

- `{{ VIDEO_ATTRIBUTES }}`

  The attributes for the video.

- `{{ VIDEO_SOURCE }}`

  The `src` attribute of the video.

- `{{ VIDEO_TYPE }}`

  The `type` attribute of the video.

## Directory Templates

### `directory.frag.html`

The directory template is used to render the contents of the **`Directory`** into the page `<body>`.

- `{{ CRUMBS }}`

  The breadcrumbs for the directory.

  Assembled from a list of directory crumb templates.

- `{{ PARENT_DIRECTORY }}`

  The Folder Listing for the parent directory.

  Used to navigate back to the parent directory.

- `{{ FOLDERS }}`

  The Folder Listings for all subdirectories.

- `{{ PINNED_ARTICLES }}`

  The Pinned Article Listings for the directory.

- `{{ HIDDEN_ARTICLES }}`

  The Hidden Article Listings for the directory.

- `{{ ARTICLES }}`

  The Article Listings for the directory.

### `directory-crumb.frag.html`

The directory crumb template is used to render a single, individual link in the directory breadcrumb.

The completed breadcrumb is assembled as a list of directory crumb templates.

- `{{ DIRECTORY_HREF }}`

  The URL of the directory.

- `{{ DIRECTORY_NAME }}`

  The name of the directory.

  Extracted from the directory folder name.

### `listing-article.frag.html`

The article listing template is used to render **`Article`** listings inside **`Directory`** pages.

- `{{ ARTICLE_HREF }}`

  The URL of the article.

- `{{ ARTICLE_TITLE }}`

  The title of the article.

  Extracted from the article filename.

- `{{ ARTICLE_DESCRIPTION }}`

  The description of the article.

  Extracted as the first paragraph following the header image.

- `{{ ARTICLE_IMAGE }}`

  The URL of the header image of the article.

### `listing-pinned.frag.html`

The pinned article listing template is used to render **`*` Pinned Article** listings inside **`Directory`** pages.

- `{{ ARTICLE_HREF }}`

  The URL of the article.

- `{{ ARTICLE_TITLE }}`

  The title of the article.

  Extracted from the article filename.

- `{{ ARTICLE_DESCRIPTION }}`

  The description of the article.

  Extracted as the first paragraph following the header image.

- `{{ ARTICLE_IMAGE }}`

  The URL of the header image of the article.

### `listing-folder.frag.html`

The folder listing template is used to render **`Directory`** listings inside **`Directory`** pages.

- `{{ ARTICLE_HREF }}`

  The URL of the directory.

- `{{ ARTICLE_TITLE }}`

  The title of the directory.

  Extracted from the directory filename.

- `{{ ARTICLE_IMAGE }}`

  The URL of the header image of the directory.

# Deployment

## GitHub Pages

Using a public GitHub repository, you can deploy your site to [GitHub Pages](https://pages.github.com/) for free.

You automatically deploy new site builds each time you push to the repository.

1. Initialize a new repository in your project.

   ```sh
   git init
   ```

2. Add a `.nojekyll` file to the root of your project, with the following content:

   ```
   touch .nojekyll
   ```

   This prevents GitHub from processing the project using Jekyll.

3. Create a [new repository](https://github.com/new) on GitHub.

4. Push your project to the repository.

5. Enable GitHub Pages for the repository.

   https://github.com/{USERNAME}/{REPOSITORY}/settings/pages

   - Select the branch to publish. Default is `main`.
   - Click **Save**.

6. Your site is live at the URL provided by GitHub.

   - https://{USERNAME}.github.io/{REPOSITORY}

7. Update the `DOMAIN` in the `ssg.config` file to match your GitHub Pages URL.

   ```
   DOMAIN="https://{USERNAME}.github.io/{REPOSITORY}"
   ```

   This is used to generate correct canonical URLs across your site build.

8. Rebuild your site & push to the repository.

9. (_Optional_) To use a custom domain, follow the [instructions provided by GitHub](https://docs.github.com/en/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site).

   Update the `DOMAIN` in the `ssg.config` file to match your custom domain.
