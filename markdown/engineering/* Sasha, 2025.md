![_`Sasha` Article Transformation, **2025**_](/public/photos/sasha/sasha-article-transformation.png "Sasha Article Transformation, Alfred R. Duarte 2025")

> [Engineering](/engineering)

# **Sasha** — Static Site Generator

> **April 2025**

### [[**View on GitHub ↗**](https://github.com/trainingmode/portfolio "GitHub — Sasha: Micro static site generator.")]{.highlight}

A simple system for writing articles and generating sites that are effortless to maintain.

Markdown **articles** & folder **directories** are rendered into **HTML** templates.

# Template System

The **template system** assembles template fragments into a final layout.

Use **`.frag.html` fragment HTML** files for templates.

## Layouts

Layout templates are used to render both **article** & **directory** pages.

Layouts follow a hierarchal order to building a final **HTML** page.

![_`Sasha` Layout Assembly Diagram, **2025**_](/public/photos/sasha/sasha-layout-assembly.png "Sasha Layout Assembly Diagram, Alfred R. Duarte 2025")

**Articles** are converted to **HTML** using **Pandoc**.

The **template system** assembles fragments and injects them into the **`layout.frag.html` Layout Template** file.

The final output is a self-contained **HTML** page.

## Replacement Tags

The **template system** uses **`{{ }}` Replacement Tags** to inject content into **template fragments**.

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

---
