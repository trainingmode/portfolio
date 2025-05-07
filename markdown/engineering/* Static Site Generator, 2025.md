![_`Sasha` Article Transformation, **2025**_](/public/photos/sasha/sasha-article-transformation.png "Sasha Article Transformation, Alfred R. Duarte 2025")

> Engineering

# Static Site Generator

> **April 2025**

### _GitHub_: **[`trainingmode/portfolio`](https://github.com/trainingmode/portfolio "trainingmode/portfolio: Micro static site generator.")**

1. [**Overview**](#overview)
2. [**Workflow**](#workflow)
3. [**Writing Articles**](#writing-articles)
4. [**Template System**](#template-system)
5. [**Portfolio Site**](#portfolio-site)
6. [**Benchmarks & Metrics**](#benchmarks-metrics)
7. [**Improvement Targets**](#improvement-targets)

### [[**→ *This site loads in under 0.8s on mobile, 0.2s on desktop***](https://pagespeed.web.dev/analysis/https-alfred-ad/6hw2k04xoa?form_factor=mobile "alfred.ad — Mobile Device Metrics — PageSpeed Insights")]{.highlight} (PageSpeed Insights)

My portfolio site is built with a custom [static site generator](https://developer.mozilla.org/en-US/docs/Glossary/SSG "Static site generator (SSG) - MDN Web Docs Glossary: Definitions of Web-related terms | MDN").

Markdown **articles** & folder **directories** are rendered into **HTML** templates.

I needed a simple system to write articles and generate a site that was effortless to maintain. My core focus was writing articles and designing a site that was **100%** accessible.

What I've learned from previous projects is to reduce or avoid complexity. I would have just written pure HTML, but that makes for a horrible experience writing neatly–formatted articles.

There is only **_`1`_** line of inline JavaScript on this site. It's on the email button CTA, needed to copy my email to your clipboard and close the context menu:

```javascript
onclick = `navigator.clipboard.writeText("alfred.r.duarte@gmail.com");this.blur();`;
```

Everything else is just **vanilla HTML** & **Tailwind CSS**.

~[autoplay muted loop playsinline width="1400" class="rounded-lg"](/public/media/alfred-portfolio-lighthouse-metrics.mp4 "video/mp4")

My [Lighthouse metrics](https://pagespeed.web.dev/analysis/https-alfred-ad/6hw2k04xoa?form_factor=mobile "alfred.ad — Mobile Metrics — PageSpeed Insights") speak for themselves.

I didn't even know it had fireworks.

#### Tools used:

- [Cursor](https://www.cursor.com/)
- [Pandoc](https://pandoc.org/)
- [Bash 5](https://www.gnu.org/software/bash/manual/bash.html)
- [Vercel serve](https://github.com/vercel/serve) (dev server)
- [Chokidar](https://github.com/paulmillr/chokidar)
- [Tailwind CSS](https://tailwindcss.com/)
- [HTML](https://html.spec.whatwg.org/multipage/)
- [Sketch](https://www.sketch.com/) (diagrams)

# Overview

Built on the **`Directory`** → **`Article`** folder structure concept. Similar to other Static Site Generators like [Jekyll](https://jekyllrb.com/ "Jekyll • Simple, blog-aware, static sites | Transform your plain text into static websites and blogs") or [Gatsby](https://www.gatsbyjs.com/ "The Best React-Based Framework | Gatsby").

It's essentially a **Markdown** converter with a simple template system. Generated sites are just HTML files, organized in the folder structure you provide in the input directory.

Internally, **articles** are converted using **Pandoc**. [Pandoc converts all files to HTML by default](https://pandoc.org/MANUAL.html#specifying-formats "Specifying formats – Pandoc – Pandoc User’s Guide"). While you could write articles in any markup format that **Pandoc** supports, only **Markdown** is supported.

A set of internal **plugins** preprocess special **Markdown** syntax, like **video** and **embedded iFrames**.

```md
# Video Component

∼[<video> Attributes](link "type")

# Example

∼[loop controls playsinline width="320" class="rounded-lg ring-(--color-primary) ring-0 ring-offset-1 hover:ring-4 active:ring-2 transition-shadow"](/public/media/alfred-portfolio-lighthouse-metrics.mp4 "video/mp4")
```

**_Output:_**

~[loop controls playsinline width="320" class="rounded-lg ring-(--color-primary) ring-0 ring-offset-1 hover:ring-4 active:ring-2 transition-shadow"](/public/media/alfred-portfolio-lighthouse-metrics.mp4 "video/mp4")

Both **article** files & **directory** folders are rendered as pages in your site. **Directory** pages display **article** listings and other **directory** subfolders.

Complete documentation can be found in the [project **`README`**](https://github.com/trainingmode/portfolio?tab=readme-ov-file#sasha--static-site-generator "trainingmode/portfolio: Micro static site generator.").

# Workflow

The **static site generator** is a set of bash scripts.

The **CLI** is used to watch the current project directory for changes and preview your site.

Your site is automatically rebuilt when the **CLI** observes any changes. You can specify an `.ssgignore` file to define excluded file/folder patterns.

A **`ssg.config` Configuration** file is created for you when you first run the **CLI**. It contains a few settings, like your domain for [canonical](https://developers.google.com/search/docs/crawling-indexing/canonicalization "What is URL Canonicalization | Google Search Central | Documentation | Google for Developers") & [Open Graph](https://ogp.me/#metadata "Basic Metadata — The Open Graph protocol") URLs. None of the settings are required.

A folder of **templates** is used to render your folder of **articles** & **directories** into **HTML** pages. The generated pages are saved into the output folder. The structure of the output folder will mirror the input folder.

## CLI

The **CLI** is the main entrypoint for the SSG.

It watches the current directory and serves your site for previewing.

```sh
./ssg.sh ssg.config "articles" "build"
```

## Builder

You can run the **Builder** manually to build your site.

```sh
./build.sh ssg.config "articles" "build"
```

The [**CLI**](#cli) can be used to watch your project directory and automatically rebuild your site.

## Development Server

The **Development Server** is a simple [serve](https://github.com/vercel/serve "vercel/serve — GitHub")–based HTTP server for previewing your site.

```sh
./server.sh 3000
```

The server isn't **WebSockets**–based, so you'll need to refresh your browser to see changes.

The [**CLI**](#cli) will automatically launch the server for you.

# Writing Articles

**Articles** are formatted in [**Markdown**](https://commonmark.org/ "CommonMark").

**Article heading images** are extracted as the **thumbnail**. The **thumbnail** is displayed in **directory** pages and for sharing on social media. The first image in the article is used.

**Article titles** are extracted from the filename. Filenames are slugified for SEO–friendly URLs.

**Article descriptions** are extracted as the first paragraph of the article.

You can define an **article category** by adding a **`>` Blockquote** before the first heading.

```md
> Case Study
# Light & Shadows
```

## Article Components

**Article components** allow you to transform content using special **Markdown** syntax.

A handful are available. Currently, they all extend the **`[]()` link`** syntax.

For example, add `+` to the beginning of a link to turn it into a **download link**.

```md
＋[Download Sketch Diagram](https://drive.google.com/uc?export=download&id=1p-IP3XXRX8CAVHfLlhyUw3MDdahVhUTv "Sasha Layout Assembly Diagram (Sketch), Alfred R. Duarte 2025.zip")
```

**_Output:_**

+[Download Sketch Diagram](https://drive.google.com/uc?export=download&id=1p-IP3XXRX8CAVHfLlhyUw3MDdahVhUTv "Sasha Layout Assembly Diagram (Sketch), Alfred R. Duarte 2025.zip")

See the [project **`README`**](https://github.com/trainingmode/portfolio?tab=readme-ov-file#article-components "trainingmode/portfolio: Micro static site generator.") for complete documentation.

## Article Listing Symbols

Special symbols are used to designate the **article listing** type.

- **`*` Pinned**
- **`~` Hidden**
- **`_` Not Rendered**

For example, `~ Hueshift, 2023.md` will render as a page, but will not be listed in any **directory** page.

# Template System

The **template system** assembles template fragments into a final layout.

It uses **`.frag.html` fragment HTML** files for templates.

There are no restrictions, and there are plenty of **`{{ }}` Replacement Tags** for injecting content parsed from your articles.

You can target **templates** to specific **articles** by mirroring the structure of your articles folder.

## Layouts

Layout templates are used to render both **article** & **directory** pages.

Layouts follow a hierarchal order to building a final **HTML** page.

![_`Sasha` Layout Assembly Diagram, **2025**_](/public/photos/sasha/sasha-layout-assembly.png "Sasha Layout Assembly Diagram, Alfred R. Duarte 2025")

**Articles** are first converted to **HTML** using **Pandoc**.

Through a series of **`{{ }}` Replacement Tags**, the **template system** assembles fragments and injects them into the **`layout.frag.html` Layout Template** file.

The final output is a self–contained **HTML** page.

## Replacement Tags

The **template system** uses **`{{ }}` Replacement Tags** to inject content into **template fragments**.

All tags are optional, and some tags can be used site–wide.

```html
<!-- Layout Template -->
 
<!DOCTYPE html>
<html lang="en">
{{HEAD}}
{{BODY}}
{{FOOTER}}
</html>
```

The [project **`README`**](https://github.com/trainingmode/portfolio?tab=readme-ov-file#templates "trainingmode/portfolio: Micro static site generator.") contains complete documentation for the **template system**.

# Portfolio Site

For my portfolio site itself, I mixed **pure HTML** with [**Tailwind CSS**](https://tailwindcss.com/ "Tailwind CSS — Rapidly build modern websites without ever leaving your HTML.") to design templates.

My portfolio site is deployed on [GitHub Pages](https://pages.github.com/ "GitHub Pages | Websites for you and your projects, hosted directly from your GitHub repository. Just edit, push, and your changes are live.").

Writing articles, designing templates, and building this SSG took blended about 3 weeks.

## Designing with Tailwind

During development, the [Tailwind Play CDN](https://tailwindcss.com/docs/installation/play-cdn "Play CDN – Tailwind CSS") was used. Performance is fairly slow loading **Tailwind** from the CDN each time a page loads.

For production, the [Tailwind CLI](https://tailwindcss.com/docs/installation/tailwind-cli "Tailwind CLI – Tailwind CSS") was used. Since **Node.js** is not used in this project, the CLI was installed via the [standalone method recommended by Tailwind](https://tailwindcss.com/blog/standalone-cli "Standalone CLI: Use Tailwind CSS without Node.js – Tailwind CSS").

```bash
curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/latest/download/tailwindcss-macos-arm64 && chmod +x tailwindcss-macos-arm64 && mv tailwindcss-macos-arm64 tailwindcss
```

It downloads as a single `tailwindcss` binary.

```bash
├── ...
└── tailwindcss
```

After installing the executable, I continued the regular [Tailwind CLI installation](https://tailwindcss.com/docs/installation/tailwind-cli "Tailwind CLI – Tailwind CSS").

First import **Tailwind** into the **main stylesheet**.

**`styles.css`**

```css
@import "tailwindcss";
```

Then replace the CDN with the **stylesheet generated by Tailwind**.

**`index.html`**

```diff
-  <script src="https://cdn.tailwindcss.com"></script>
+  <link rel="stylesheet" href="/public/tailwind.css" />
```

Finally, compile **Tailwind**.

The **`-m` minifier** reduces the output size.

The **`-w` watcher** observes changes in your project and automatically rebuilds the Tailwind stylesheet.

```bash
./tailwindcss -i "./public/styles.css" -o "./public/tailwind.css" -m -w
```

In total this setup took about 5–10 minutes.

This was my first time using **Tailwind** with vanilla HTML and I really enjoyed it. Using it with my **template system** felt like a natural extension from other technologies like [React](https://react.dev/ "React").

# Benchmarks & Metrics

***Every single page on my site achieves `100` Best Practices & SEO scores.***

Certain pages on my site achieve perfect **`100`** scores on [PageSpeed Insights](https://pagespeed.web.dev/analysis/https-alfred-ad/6hw2k04xoa?form_factor=mobile "alfred.ad — Mobile Device Metrics — PageSpeed Insights") (Lighthouse).

![_Alfred Portfolio Home Page Lighthouse Metrics, **2025**_](/public/photos/sasha/portfolio-home-lighthouse-metrics.png "Alfred Portfolio Home Page Lighthouse Metrics, Alfred R. Duarte 2025")

***There are zero errors site-wide.***

![_Alfred Portfolio Clean Console Logs, **2025**_](/public/photos/sasha/portfolio-clean-console-logs.png "Alfred Portfolio Clean Console Logs, Alfred R. Duarte 2025")

## Lighthouse Metrics

Below are a sampling of [Lighthouse](https://developer.chrome.com/docs/lighthouse "Lighthouse | Chrome for Developers") reports (via **PageSpeed Insights**) for some pages.

Metrics are based on **mobile devices**.

|   | **FCP** | **LCP** | **Speed Index** | **Performance** | **Accessibility** | **Report** |
| --- | --- | --- | --- | --- | --- | --- |
| [`/`](/ "Alfred R. Duarte \| Portfolio Home") | **`0.8s`** | **`0.8s`** | **`0.8s`** | ✅ **`100`** | ✅ **`100`** | [PageSpeed](https://pagespeed.web.dev/analysis/https-alfred-ad/q7m2zpfdhr?form_factor=mobile "alfred.ad — Mobile Device Metrics — PageSpeed Insights") |
| [`/design`](/portfolio/design/ "Design \| Alfred R. Duarte \| Portfolio") | **`0.9s`** | **`8.7s`** | **`3.5s`** | 🟡 **`74`** | ✅ **`100`** | [PageSpeed](https://pagespeed.web.dev/analysis/https-alfred-ad-portfolio-design/unm40zyykf?form_factor=mobile "alfred.ad/portfolio/design — Mobile Device Metrics — PageSpeed Insights") |
| [`/design/emojis`](/portfolio/design/color-emoji-ios-6-2022/ "Color Emoji (iOS 6), 2022 \| Alfred R. Duarte \| Portfolio") | **`0.9s`** | **`15.5s`** | **`3.5s`** | 🟡 **`74`** | 🟡 **`86`** | [PageSpeed](https://pagespeed.web.dev/analysis/https-alfred-ad-portfolio-design-color-emoji-ios-6-2022/m1nut8tn2d?form_factor=mobile "alfred.ad/portfolio/design/color-emoji-ios-6-2022 — Mobile Device Metrics — PageSpeed Insights") |

**Performance** drops when a page includes a lot of media.

**Accessibility** drops a bit on **article** pages due to the way some headings are used.

Personally, I think semantically skipping an `<h2>` to create a subheading `<h3>` is perfectly reasonable. It also reads in plain English—_the subheading before the following section_.

```md
# Title

### Subheading ←[ Triggers Accessibility Error ]

## Section
```

**Deployed sites** ship with only what they need. A generated **article** page is only a few dozen kilobytes in size. Media used in an **article** will increase its page size.

My [Emoji Case Study](/portfolio/design/color-emoji-ios-6-2022/ "Color Emoji (iOS 6), 2022 | Alfred R. Duarte | Portfolio") page is **`13.5MB`** including images and transfers in **`246ms`**.

![_Alfred Portfolio Network Load, **2025**_](/public/photos/sasha/portfolio-network-load.png "Alfred Portfolio Network Load, Alfred R. Duarte 2025")

As you can see, images are the largest bottleneck. Currently there is no image optimization (lazy loading, serving smaller images for mobile, etc). This is a clear target for future optimization.

## Builder Benchmarks

An article with **`2069`** words (my [**Dataing**](/portfolio/design/dataing-2023-2025/ "Dataing, 2023-2025 | Alfred R. Duarte | Portfolio") article) renders in around **`64ms`**.

![_`Sasha` Terminal Output, **2025**_](/public/photos/sasha/sasha-terminal-output.png "Sasha Terminal Output, Alfred R. Duarte 2025")

My entire portfolio site with **`10`** articles renders in just under **`3s`**. It's lengthy but doesn't feel too bad when writing articles.

This could be improved by only rebuilding changed articles. However, it would require hacking the **chokidar-cli** output to determine which files changed.

It would make more sense to translate the **CLI** to **Node.js** and use **WebSockets** to trigger rebuilds. For this project, this was an acceptable compromise given I was focused primarily on writing articles.

# Improvement Targets

There are a handful of targets for improvement that exceeded the initial scope of this project.

I was mainly focused on writing articles for my portfolio and didn't want to add complexity.

- **Image Optimization**  
  _Impact_: 🔴 **_Critical_**  
  Images are served at their original size. This could be improved with build-time optimization to resize & compress images. This would significantly reduce page size and thusly data usage for mobile users.

- **Node.js Translation**  
  _Impact_: 🟡 _Low_  
  The **CLI** is a shell script. Rewriting the **CLI** in **Node.js** would improve developer experience, and allow for extended features like WebSockets & plugins.

- **Targeted Rebuilds**  
  _Impact_: 🟡 _Low_  
  Every change currently triggers a full site rebuild. **Hashing files** & building a **dependency graph** would allow for granular rebuilding of only files that changed. This would significantly reduce build times.

- **WebSockets**  
  _Impact_: 🔵 _Feature_  
  Browsers must be manually refreshed to see changes after rebuilds. WebSocket-based **hot reloading** would enable immediate visual feedback while writing articles. This would greatly improve the experience for content creators.

In all, I'm satisfied with performance results and **CLI** UX given the scope.

Removing complexity from this project taught me a lot about focusing on the core experience.

Performant & accessible design can look beautiful, too.

---

### [🧑🏽‍💻 **Book a meeting to discuss your project. [→](mailto:alfred.r.duarte@gmail.com)**]{.highlight}

[**alfred.r.duarte@gmail.com**](mailto:alfred.r.duarte@gmail.com "Gmail – Alfred R. Duarte")

