![_Static Site Generator Terminal Output, **2025**_](/public/photos/misc/ssg-terminal-output.png "Static Site Generator Terminal Output, Alfred R. Duarte 2025")

# Static Site Generator

> **April 2025**

### `⚠️` **_`This article is under construction.`_**

### _GitHub_: **[`trainingmode/portfolio`](https://github.com/trainingmode/portfolio "Alfred R. Duarte Portfolio GitHub")**

1. [**Workflow**](#workflow)
2. [**Template System**](#template-system)

My portfolio site is built with a custom static site generator.

Built on the **`Directory`** → **`Article`** folder structure concept. Similar to other Static Site Generators like [Jekyll](https://jekyllrb.com/ "Jekyll • Simple, blog-aware, static sites | Transform your plain text into static websites and blogs") or [Gatsby](https://www.gatsbyjs.com/ "The Best React-Based Framework | Gatsby").

For this project, I mixed **pure HTML** with **Tailwind CSS** (via CDN) for the template system. Generated sites are pretty lightweight, with only the Tailwind CDN dependency.

Internally, **articles** are converted using **Pandoc**. While **Markdown** is preferred, Pandoc will [convert all files to HTML by default](https://pandoc.org/MANUAL.html#specifying-formats "Specifying formats – Pandoc – Pandoc User’s Guide"). You could write articles in any markup format that **Pandoc** supports.

I wrote a set of internal **plugins** to preprocess special Markdown syntax, like **embedded iFrames** and **image comparisons**.

I've previously developed a [full-fledged SSG](https://alfred.ad/portfolio/engineering/under-construction/ "UNDER CONSTRUCTION"), with a [CommonMark](https://commonmark.org/ "CommonMark") parser from scratch, but I just needed a quick implementation to quickly get my site running.

What I've learned from previous projects is to reduce or avoid complexity. I would have just written pure HTML, but that makes for a horrible experience writing articles.

#### Tools used:

- [Cursor](https://www.cursor.com/)
- [Pandoc](https://pandoc.org/)
- [Bash 5](https://www.gnu.org/software/bash/manual/bash.html)
- [Vercel serve](https://github.com/vercel/serve) (dev server)
- [Chokidar](https://github.com/paulmillr/chokidar)
- [Tailwind CSS](https://tailwindcss.com/)
- [HTML](https://html.spec.whatwg.org/multipage/)

# Workflow

The **static site generator** is a set of bash scripts.

I had a neatly organized folder of Markdown articles.

I had an accompanying folder of HTML templates–organized in an indentical structure–that I wanted .

## Builder

## Development Server

## Auto-Rebuilder & Watcher

# Template System

## Layouts

## Features

## Tag Replacements

---

#### [`🧑🏽‍💻`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte") **_`Book a `[`meeting`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte")` to discuss your project.` [`➔`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte")_**

.
