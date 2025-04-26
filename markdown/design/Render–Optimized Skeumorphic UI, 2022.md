![_UI 1 – Analog Designs UI Styles Ⅰ, **2022**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui1-preview.png "UI 1 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022")

> Case Study — Design

# Render–Optimized Skeumorphic UI

> **October** - **December 2022**

1. **[Purpose](#purpose)**
2. **[Process](#process)**
3. **[Fantasy Plugins](#fantasy-plugins)**
4. **[Symbols](#symbols)**

![_Sample UIs 1-7 on Desktop – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui-1-7-desktop.png "Sample UIs 1-7 on Desktop – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

_**All of the interface assets I created in this project are purely vector-based**, excluding some image-based textures._

#### 🎚️ Assets produced:

**`282`** **Assets**

- **`30`** **Panels**
- **`38`** **Knobs**
- **`14`** **Sliders**
- **`26`** **Buttons**
- **`58`** **Accessories**
- **`11`** **Textures**
- **`5`** **Fonts**

**`225`** **Symbols**

#### Tools used:

- [Affinity Designer](https://affinity.serif.com/en-us/designer/)

## Purpose

A **music plugin** is an interface users interact with to control parameters of an **audio processing pipeline**.

Important to note, the interface is just a skin. The _audio processor_ is the main consumer of resources. This means interfaces need to be lightweight and mindful of performance overhead.

_Audio processing_ happens in realtime on the **CPU**. Plugin UIs need to offload as much rendering as possible to the **GPU**. In practice, this means reducing the amount of **draw calls** & **vertex buffers** (typically w/ _subranging_ & _instancing_) processed by the **CPU**.

For example, reallocating one (large) **VBO** vs. updating separate **VBOs** for each plugin window instance can free up **CPU**. Rather than your **CPU** processing each instance (`O(n)`), it can process a single **VBO** for all instances and upload it to the **GPU** (`O(1)`). Optimizations like this are crucial when you rely on individual-frame performance optimizations.

Each frame of processing (both _audio_ & _UI_) needs to happen in as little time as possible. Otherwise, you risk glitching & artifacts in your audio output.

That's what the **buffer size** on your **audio interface** is for–adjusting the amount of audio samples processed per frame. A larger buffer size means more samples are processed, but at the expense of latency (the audio playing back later than it appears on the screen).

A **music plugin host** dispatches each chunk of samples at a consistent interval (the **buffer size**). If a frame stalls or exceeds its buffer period, the following frame will not start in time and underrun the buffer.

```
╭< Frame 1 >  ╭< Frame 2 >  ╭< Frame 3 >
├ ✓ 10ms      ├ ⨯ 20ms      ├ ✓ 10ms
│ Pass        │ Underrun →  │ Artifacts
```

### Rendering Options

For rendering music tooling interfaces in software, you have a few options:

1. **Image textures (e.g. PNG)**
2. **Vector-based renderer**
3. **3D-based renderer**, (_can include shading pipelines_)

**Image textures** are the most common, being the easiest and least resource intensive. You get detailed designs without the overhead.

They have their obvious limitations. Fixed sizing is a major issue for distribution across the wide array of desktop screen sizes & resolutions. (_Looking at you, ultrawide screen users._)

To scale the window for an **image texture**-based UI, you need to include different sizes of all your images for each target window scale. Otherwise, elements of your UI will look pixelated/blurry when scaled up.

Another slowdown is the workflow for rendering animation sequences. You have to render _each frame_ as an image, then assemble it as an **animation strip**. There are [many](https://navelpluisje.github.io/figma-knob-creator "Figma Knob Creator | A Figma plugin for creating knob stacks") [tools](https://tripletechaudio.com/products/knob-maker-for-vst/ "Knob Maker - TripleTech") that can help automate this process. I need to mention the web version of the classic [KnobMan by g200kg](https://www.g200kg.com/en/webknobman/index.html?f=3p_wedge.knob&n=2 "WebKnobMan Knob Designer | g200kg Music & Software") that has been used to render knobs & sliders for countless music plugin UIs throughout the decades.

![_Knob 22 Animation Sequence – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-knob22-sequence.png "Knob 22 Animation Sequence – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

**Vector-based renderers** solve the sizing issue, but can incur significant performance overhead with the number of moving/animated parts in a music plugin UI.

Lots of vector-based plugins simplify graphical complexity to make up for the increase in overhead, and craft unique stylized looks.

![_[FabFilter Pro-Q 4](https://www.fabfilter.com/products/pro-q-4-equalizer-plug-in "FabFilter Pro-Q 4 - Equalizer Plug-In") Plugin UI Screenshot, **FabFilter 2025**_](/public/photos/misc/fabfilter-pro-q-4.jpg "FabFilter Pro-Q 4 Plugin UI Screenshot, FabFilter 2025")

The cost of **3D-based renderers** both to develop & create assets for, plus the overhead of rendering in realtime, means most music plugins don't use them.

Instead, plugins with 3D-based elements just render static images and animate the image sequences. Some plugins blend rendered elements with vector-based interactive elements. This way, continuous animation is smooth without most of the overhead cost.

![_[Arturia Jup-8 V](https://www.arturia.com/products/software-instruments/jup-8-v/overview "Arturia - Jup-8 V") Plugin UI Screenshot, **Arturia 2025**_](/public/photos/misc/arturia-jup-8-v.png "Arturia Jup-8 V Plugin UI Screenshot, Arturia 2025")

### Project Goals

The goal of this project was to develop a set of **vector-based techniques for rendering skeumorphic music plugin UIs**.

The idea is that the UI would be drawn:

- **Once (`1`) when the plugin window is first opened/drawn**
- **When the user resizes the plugin window**, (_continuous_ or _throttled_/_debounced_)

This ensures the UI can be truly responsive–and always drawn perfectly to scale–while reducing overhead.

![_Sample UI 1 Close-up – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui1-closeup.png "UI 1 Close-up – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

_Localized areas_ are then redrawn as needed for:

- **Parameter changes** (e.g. user adjusts a knob)
- **State changes** (e.g. user hovers over a button)
- **Animation** (e.g. spectrum analyzer graph)

Animation for controls like knobs & sliders can be **fully continuous** and still stay lightweight.

This eliminates the need for prerendered animation assets, constructing animation strips, and prerendering multiple sizes of the same asset for each target window scale.

**Flat-shading** is the final component to reducing **draw calls** & **vertex buffers** processed by the **CPU**. No _lighting_ (faster frag shaders), no _normals_ (even faster), no _specular_; _zero physically-based rendering_. Just flat colors & gradients. Even shadows are flat gradients.

## Process

I collected a set of **`57` music interface references**, ranging from vintage hardware to modern software.

I analyzed common controls, the styles used to convey functionality, and user experience patterns between interfaces. 'Lotta knobs.

![_Reference Interfaces, **Google Images 2022**_](/public/photos/analog-designs/analog-designs-ui-styles-i-references.png "Reference Interfaces, Google Images 2022")

Each control follows a predictable layer architecture. For each control type–knobs, sliders, & buttons–I constructuced reusable architecture for building new controls.

Below is an example of **`Knob 22`** and its structure.

![_Knob 22 Anatomy – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-knob-anatomy.png "Knob Anatomy – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

The two bottom layers, **Ring Notches** & **Base Border**, are static.

The two top layers, **Top Face** & **Indicator**, can be animated depending on the design of the control.

Certain designs may only need to animate the **Indicator** **CPU**-side, animating gradients **GPU**-side.

A key aspect to these techniques is **minimizing the amount of vector data** processed by the **CPU**.

The lower the amount of animated vertices, the lower the **CPU** processing. The lower the amount of vertices alltogether, the greater the amount of window instances that can be drawn together.

![_Knob 22 Vector & Outlines Dissection – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-knob22-dissection.png "Knob 22 Dissection – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

Vertex counts can rise slightly, as long as the high-vertex element either remains static (only drawn on window context change) or can be offloaded & animated **GPU**-side.

Remember our knob animation from earlier in the article. Rather than continuous animation, costing calculations for each frame of rotation animation, a _lookup table_ can be used to store values used in the animation.

Controls with discrete/stepped values can take this a step further and reduce the number of intervals stored in the LUT.

![_Knob 22 Animation Sequence Breakdown – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-knob22-sequence-breakdown.png "Knob 22 Animation Sequence Breakdown – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

In fact, you can just precompute curve values into a LUT and reuse for drawing each unchanged frame of animation.

Design choices can close the loop and further reduce processing involved. You don't need your **CPU** to calculate vertices of a perfect circle when your **GPU** can do it. A perfect circle doesn't need a LUT for rotation values.

The combination of these techniques can reduce **CPU** load for skeuomorphic-style interfaces, while still allowing for high-quality, responsive, & scalable interfaces.

![_Sample UI 1 Vector & Outlines Dissection – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui1-dissection.png "UI 1 Dissection – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

## Fantasy Plugins

Below are a handful of fantasy music plugin UIs I threw together in a few hours.

None of the interfaces below were orignally designed as a cohesive unit–they were all assembled using separate assets from this set.

All of the interfaces below are fully vector-based.

![_Sample UI 1 – Analog Designs UI Styles Ⅰ, **2022**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui1.png "Sample UI 1 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022")

![_Sample UI 2 – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui2.png "Sample UI 2 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

![_Sample UI 3 – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui3.png "Sample UI 3 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

![_Sample UI 4 – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui4.png "Sample UI 4 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

![_Sample UI 5 – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui5.png "Sample UI 5 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

![_Sample UI 6 – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui6.png "Sample UI 6 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

The legality surrounding the exclusion of woodgrain textures from a set of music plugin UIs is a bit of a gray area. I've included a sample with woodgrain below to ensure compliance.

![_Sample UI 7† – Analog Designs UI Styles Ⅰ, **2022 & 2025**_](/public/photos/analog-designs/analog-designs-ui-styles-i-ui7.png "Sample UI 7 – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022 & 2025")

† _Sample UI 7 contains an image texture for the woodgrain side panels._

## Symbols

Included with the set are `225` **line icon symbols**.

I wanted to experiment with an idea I had for constructing the **grid** & **guide system**.

![_Flag Symbol with Guides – Analog Designs UI Styles Ⅰ, **2022**_](/public/photos/analog-designs/analog-designs-ui-styles-i-symbol-guides.png "Flag Symbol with Guides – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022")

I used concepts from [shape building](https://helpx.adobe.com/illustrator/using/building-new-shapes-using-shape.html#shape-builder "Build new shapes with Shaper and Shape Builder tools – Adobe Illustrator Help") to **anticipate curves & placements into a set of guides**.

![_Symbol Samples – Analog Designs UI Styles Ⅰ, **2022**_](/public/photos/analog-designs/analog-designs-ui-styles-i-symbols.png "Symbol Samples – Analog Designs UI Styles Ⅰ, Alfred R. Duarte 2022")

My conclusions of the **guides** were mixed.

The **guides** did help speed up creation by helping me quickly place curves. But I also found them a bit restrictive for some compositions. I'll likely stick with something more traditional for most projects.

---

#### [`🎛️`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte") **_`Book a `[`meeting`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte")` to discuss your project.` [`➔`](mailto:alfred.r.duarte@gmail.com "Calendly – Alfred R. Duarte")_**

.
