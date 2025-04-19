![_Hueshift Palette Board, **2023**_](/public/photos/bloomhue/hueshift-board.png)

# Hueshift (Design)

> **March** - **April 2023**

> _**Note**: For an engineering perspective on this project, please see [here](/projects/engineering/UNDER%20CONSTRUCTION/)._

### `📚` **_`Book a `[`meeting`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte")` to discuss your project.` [`➔`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte")_**

1. [**Purpose**](#purpose)
2. [**Interface Design**](#interface-design)
3. [**User Experience & Testing**](#user-experience-testing)
4. [**Try Hueshift.io 🎨 🖼️**](#try-hueshift.io)

![_254 Spectrum Made with Hueshift, **2025**_](/public/photos/bloomhue/254-hueshift-spectrum.png "254 Spectrum, Hueshift, Alfred R. Duarte 2025")

Often in design, you'll need to take a [color palette](https://en.wikipedia.org/wiki/Color_scheme "Color scheme – Wikipedia") and define a [set of light to dark steps](https://en.wikipedia.org/wiki/Color_scheme#Quantitative_schemes "Quantitative schemes – Wikipedia") for each color.

![_Warm Palette Extended with Hueshift, **2025**_](/public/photos/bloomhue/palette-to-hueshift-perspective.png "Extended Warm Palette Spectrum, Hueshift, Alfred R. Duarte 2025")

In **interface design**, these values can be used to create _depth_ and _dimension_.

One color with a **lighter** and **darker** step can be overlaid to produce elements with a monochrome, "_single color_" look.

![_Confirmed Label with 131 Hueshift Palette, **2025**_](/public/photos/bloomhue/hueshift-example-confirmed-label.png "Confirmed Label with 131 Hueshift Palette, Alfred R. Duarte 2025")

It helps you **layer related information** in a predictable pattern to how colors **increase & decrease** in **lightness & darkness**.

Just one color can touch a range of situations, with a clear separation of information.

![_Grid of Cards with 29 Hueshift Palette, **2025**_](/public/photos/bloomhue/29-hueshift-palette-overlay.png "Grid of Cards with 29 Hueshift Palette, Alfred R. Duarte 2025")

This predictability can be especially useful when creating **light & dark themes**. It's easier to balance your main _accent_ shade against your _background_ & _foreground_ colors when you have steps that feel natural in distance.

![_Light & Dark Themes with 222 Hueshift Palette, **2025**_](/public/photos/bloomhue/hueshift-example-light-dark-theme.png "Light & Dark Themes with 222 Hueshift Palette, Alfred R. Duarte 2025")

It's also useful when creating subtle shading with a natural feel, while maintaining vibrant readability.

![_Graph – Analog Designs UI Styles I, **2023**_](/public/photos/analog-designs/analog-designs-uistyles1-graph.png "Graph – Analog Designs UI Styles I, Alfred R. Duarte 2023")

I created **Hueshift** as a tool to automate this process. It uses a [two-stage machine learning process](/projects/engineering/UNDER%20CONSTRUCTION/ "UNDER CONSTRUCTION | Alfred R. Duarte | Portfolio") to help you:

- **Choose interesting colors that complement each other.**
- **Automatically generate a set of light to dark shades for each color.**

**_There are no high-fidelity mockups for this project. Hueshift was designed & built directly in React._**

#### Tools used:

- [VS Code](https://code.visualstudio.com/)
- [React](https://react.dev/)
- [Tailwind CSS](https://tailwindcss.com/)
- [Affinity Designer](https://affinity.serif.com/en-us/designer/) (Figure Diagrams & Example References)
- [Hueshift](https://hueshift.io/) (Color Palettes for Figure Diagrams)

## Purpose

What I found lacking in similar tools are the methods of generating **harmonious colors**.

Most tools are limited to either [mathematical methods](https://en.wikipedia.org/wiki/Color_scheme#Harmonious_schemes "Harmonious schemes – Color scheme – Wikipedia"), or _manual selection_.

I wanted to create a tool that bridged the gap between mathematical precision and the organic artistry of human-selection.

**Hueshift** recursively generates harmonious colors starting from the **base hue**.

This method allows for a wider range of generated palettes, with colors that still feel naturally harmonious.

## Interface Design

**Hueshift** takes on an interface that is purposefully _form_ over _function_.

In a world where UI is reduced to a single chat box, I wanted to take a different approach.

I wanted to imagine an interface that is as **engaging & artistically inspiring** as it is **functional to use**.

### Inspiration

Inspiration for the **palette board** came from those wall of swatches inside real-world paint stores.

![_Wall of Swatches, **GPT-4o 2025**_](/public/photos/misc/swatch-board.png "an image of a wall of swatches at a paint store, iphone shot")

The **palette board** attempts to capture the dynamic nature of a real-world swatch wall in a paint store.

![_Hueshift Compact Palette Board Close-up, **2023**_](/public/photos/bloomhue/hueshift-board-compact-closeup.png "Hueshift Compact Palette Board Close-up, Alfred R. Duarte 2023")

### Features

**Hueshift** is highly interactive.

You can click to copy any **shade** as a **hex code**.

You can **drag & drop** rows of swatches to reorder them or toss them out.

![_Swatch Drag & Drop on Hueshift Palette Board, **2023**_](/public/photos/bloomhue/hueshift-board-drag-drop-swatch.png "Swatch Drag & Drop on Hueshift Palette Board, Alfred R. Duarte 2023")

Using the **sliders**, you can adjust the **hue** of the **base color**. You can also adjust palette-wide **lightness & saturation**.

You can generate up to **`8` harmonious color swatches** in a single palette.

![_Hueshift Sliders, **2023**_](/public/photos/bloomhue/hueshift-sliders.png "Hueshift Sliders, Alfred R. Duarte 2023")

Enable **Greytone** to generate a **greyscale** palette.

![_Hueshift Greytone Palette, **2025**_](/public/photos/bloomhue/hueshift-greytone-palette.png "Hueshift Greytone Palette, Alfred R. Duarte 2025")

You can copy rows of swatches as **JSON**, or copy the entire palette as **JSON**.

Click the **`Palettes ⬇️`** button to download a `palette.json` file of all your starred palettes.

```json
{
  "50": "#f2fdfc",
  "100": "#cbfbf6",
  "200": "#98f6ef",
  "300": "#5deae6",
  "400": "#2bd4d2",
  "500": "#14b6b8",
  "600": "#0d9196",
  "700": "#0f7175",
  "800": "#115a5f",
  "900": "#134b4e",
  "950": "#042a2f",
  "hue": 180
}
```

With **Hueshift Pro**, you can edit the colors used to influence the **model** that generates _harmonious colors_.

![_Hueshift Model Selector, **2023**_](/public/photos/bloomhue/hueshift-models.png "Hueshift Model Selector, Alfred R. Duarte 2023")

If you feel like shades generated are "missing something", you can add or remove colors to influence the **model** to generate entirely new shades and palettes.

**Hueshift** ships with **_`98`_** pre-defined **color models**, with `21` **color models** enabled by default.

It also ships with **_`19`_** **greytone models**, with `5` **greytone models** enabled by default.

## User Experience & Testing

I conducted light **user testing** with some designer & marketing friends to see how they used **Hueshift** and their thoughts on the process provided by the tool.

![_Hueshift Palette Board Close-up, **2023**_](/public/photos/bloomhue/hueshift-board-closeup.png "Hueshift Palette Board Close-up, Alfred R. Duarte 2023")

### Testing Process

Feedback was collected through various forms, mainly **text messaging** and **Discord**. With a small test group, I wanted to meet people where they were.

I sent around a survey as text that people could easily reply to rather than ask them to fill out a form. I provided an open space for suggestions & comments.

I sent them a succinct set of targeted questions to understand their usage patterns:

1. **Did you produce any palettes that you used, or would use in a project?**
2. **Was there any point you said, "_I hope/wonder if Hueshift could do this?_" What were trying to do?**
3. **What did you find cumbersome about the process or interface?**
4. **What reasons hold you back from using Hueshift in your workflow?**

### Feedback Summary

> _"...really fun to play with!"_

Through this research, the feature for **dragging a row of swatches out of the palette to remove it** surfaced. Many people didn't understand how to get rid of swatches that they didn't want, and just wanted to "toss them out".

I also received feedback from basically everyone for one feature:

> _"Can I generate a palette from an image?"_

While this was out of the project scope, it's a great suggestion for a future release.

### Conclusions

In all, most found the process mostly intuitive and easy to navigate. However, no designers really mentioned they'll actually use the tool. The honest feedback I received was picking colors manually in-app was just quicker and easier than using a totally separate tool.

With that said, my marketing friends were very excited about its potential, but it was still just a bit too hands-on for them.

I would like to revisit this project and incorporate the feedback I received. I think making the process even more streamlined would help increase the tool's usability and get people to actually adopt it.

## Try Hueshift.io 🎨 🖼️

Embedded below ⬇️ or at [beta.hueshift.io](https://beta.hueshift.io "Hueshift.io") (_best viewed in a separate tab_).

#### Tips:

- Click the <span class="inline-block text-blue-500"><svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="size-4"> > <path stroke-linecap="round" stroke-linejoin="round" d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z" /> > </svg></span> **`Help`** button to open the **Help Guide**.

- Switch your system color scheme to see **light** and **dark** modes.

- Click **`Upgrade to Pro`** to unlock the **Full Version** of the app (it's free).

@[115%](https://beta.hueshift.io/)

.
