![_iOS 6-style Emoji Grid, **2022**_](/public/photos/spaceboy3000/ios6-emoji-grid.png "Emoji Grid, Alfred R. Duarte 2022")

> Case Study — Design

# Color Emoji (iOS 6.0)

> **June 2022**

1. [**Secrets of Emoji Design**](#secrets-of-emoji-design)
2. [**Anatomy of Emoji**](#anatomy-of-emoji)
3. [**Dissection & Outlines**](#dissection-outlines)
4. [**Comparisons & Close-ups**](#comparisons-close-ups)
5. [**Side-by-Side Comparison**](#side-by-side-comparison)

I've always loved **Apple**'s [icon design](https://developer.apple.com/design/human-interface-guidelines/icons "Apple Human Interface Guidelines: Icons"). Their depth and precision is truly inspiring.

The set of original **iOS 6.0** emoji are timeless & iconic. Their style set the standard for emoji design.

I wanted to take a look and see how the original emoji were made. If you try to blow emoji up to a large size, you'll find they're just images. The [original designers have shared](https://blog.emojipedia.org/who-created-the-original-apple-emoji-set/ "Who Created The Original Apple Emoji Set? – Emojipedia") that they were digital paintings, but I wanted to see what I could do using vector alone.

Recently, I had just completed a similar [case study on pushing the limits of vector shapes & gradients for UI design](/portfolio/design/case-study-ui-styles-i-2022/ "Case Study: UI Styles I, 2022 | Alfred R. Duarte | Portfolio"). That project equipped me with very delicate _shading_ & _composition_ techniques using only vector. I wanted to see how those same techniques could apply to the depth & detail of emoji design.

**_All of the emoji I created in this project are purely vector-based._**

> _**Disclaimer**: I am **not affiliated** with Apple. Emoji referenced in comparisons are **unmodified** and used for educational purposes only. Close-ups & breakdowns are all my own work._

#### Assets produced:

**`56`** **Expressions**

- **`5`** **Heads**
- **`33`** **Eyes**
- **`18`** **Eyebrows**
- **`29`** **Mouths**
  - **`3`** **Teeth**
  - **`3`** **Tongues**
  - **`2`** **Cheek Blushes**
  - **`1`** **Chin**
- **`12`** **Accessories**

**`21`** **Bonus**

- **`4`** **People**
- **`1`** **Heart**
- **`16`** **Symbols**

#### Tools used:

- [Affinity Designer](https://affinity.serif.com/en-us/designer/)

## Secrets of Emoji Design

![_[Sun](https://emojipedia.org/apple/ios-6.0/sun "Sun on Apple iOS 6.0 – Emojipedia") & [Surprised](https://emojipedia.org/apple/ios-6.0/face-with-open-mouth "Surprised Face with Open Mouth on Apple iOS 6.0 – Emojipedia") Emoji Overlap, **Apple Color Emoji (iOS 6.0) 2012**_](/public/photos/spaceboy3000/emoji-overlap-sun-surprised.png "Sun & Surprised Emoji Overlap, Apple 2012")

_Which came first_–the **_sun_** or the **_surprised face_**?

I was browsing the original emoji set looking for strong reference candidates. I noticed the shading for the body of the **sun** emoji was nearly identical to the body of the **emoji face**/**head**.

Rather than attempt an emotive emoji, I decided to use the **sun** emoji as my starting reference for breaking down the anatomy of the **emoji face**.

While I can't unmask specifics around my techniques, I can share about the principles I used and my process behind breaking down **Apple**'s emoji design.

### Light & Scene

Apple designers carry a strong understanding of _physical-based_ **light** & **scene composition**.

![](/public/photos/spaceboy3000/emoji-scene-composition.png "Emoji Scene Composition Diagram, Alfred R. Duarte 2025")

Emoji take on _studio-quality lighting_, likely from a **3-point lighting setup** (not pictured).

A strong **light source** seems to be positioned vertically above the emoji, casting a strong _highlight_ on subjects. **Fill** & **back lighting** are used to create a sense of depth, reducing contrasting shadows while maintaining vibrancy.

#### **_A Word on the Physical Properties of Light_**

The **light spectrum** is a range of _wavelengths_.

These are broken into `3` categories:

- **Infrared** wavelengths, low energy, longer than red;
- **Visible** wavelengths, medium energy, between red and blue;
- **Ultraviolet** wavelengths, high energy, shorter than blue.

Notice the colors: **red** & **blue**.

When you shift colors, imagine the wavelengths of light.

You're shifting more 🔴 **red**, or more 🔵 **blue**.

🔴 **Red** is lower energy and _darker_. 🔵 **Blue** is higher energy and _brighter_.

### Object Composition

As previously mentioned, emoji were originally digital paintings. Objects don't really follow [shape-building principles](https://helpx.adobe.com/illustrator/using/building-new-shapes-using-shape.html#shape-builder "Build new shapes with Shaper and Shape Builder tools – Adobe Illustrator Help") like we're used to seeing from **Apple**'s iconography.

With that said, their emoji are still highly compositional, with mostly-geometric shapes used to build objects.

![_Sun Emoji Vector & Outlines Dissection, **2025**_](/public/photos/spaceboy3000/emoji-dissection-sun.png "Sun Emoji Dissection, Alfred R. Duarte 2025")

**Apple** designers likely **painted onto flat shapes** to create depth and simulate light. They likely used a combination of **layer effects** as well as the trusty **brush tool** to create the final look.

My own technique reuses shape layers with gradients to construct depth out of as few vertices as possible. This to offload processing required by the **CPU** and relying on shaders to push intensive rendering work on the **GPU**.

### Edges, Faces, & Bodies

In typical **Apple** style, much focus is placed on **edge definition**. **Edges** capture _shape_ & _form_ to create their signature sense of depth.

**Edges** & **faces** catch light to build _definition_.

**Faces** mold form and express _physicality_. These are material-based properties, like _specular_, _diffuse_, _ambient_; to portray things like _roughness_, _glossyness_, etc.

**Bodies** cast shadow and fill light-space for a sense of _volume_.

![_Sun Emoji Close-up, **2022**_](/public/photos/spaceboy3000/emoji-closeup-sun.png "Sun Emoji Close-up, Alfred R. Duarte 2022")

### Blending & Gradients

The key to achieving the classic **Apple** emoji look is **blending**.

Understanding how [physical light sources interact](#a-word-on-the-physical-properties-of-light) with materials and with one another is key.

![_Fire Emoji Close-up, **2022**_](/public/photos/spaceboy3000/emoji-closeup-fire.png "Fire Emoji Close-up, Alfred R. Duarte 2022")

**Strong composition** lays the foundation for vibrant _blending_ work.

The classic approach of using a **base**, with **layers of shading** to create _depth_ is how you produce strong results.

Take extra care of how you shape **edges** and **faces** against the scene lighting.

![_Fire Emoji Base Gradient & Shading Dissection, **2025**_](/public/photos/spaceboy3000/emoji-dissection-fire.png "Fire Emoji Base Gradient & Shading Dissection, Alfred R. Duarte 2025")

## Anatomy of Emoji

Emoji rely heavily on strong principles of **light** & **blending**.

**Lines** take _shape_ and mold _form_ into the face base. **Gradients** capture depth from the light cast on the face surface.

Emoji can be broken into two main parts: **face** & **expression**.

### Emoji Face Anatomy

The **face** is the foundation for all emotive emoji.

![](/public/photos/spaceboy3000/emoji-face-anatomy.png "Emoji Face Anatomy Diagram, Alfred R. Duarte 2025")

The emoji **face** is split into `5` layers:

1. **Highlight**
2. **Flush**
3. **Border**
4. **Base**
5. **Shadow**

This anatomy is identical for all emotive emoji. This includes the [😡 **Enraged Face**](https://emojipedia.org/apple/ios-6.0/pouting-face "Enraged Face on Apple iOS 6.0 – Emojipedia") emoji, which takes on a full-face **flush**. The **base** & **border** are only recolored for the two [😈 **Smiling Face with Horns**](https://emojipedia.org/apple/ios-6.0/smiling-face-with-horns "Smiling Face with Horns on Apple iOS 6.0 – Emojipedia") & [👿 **Angry Face with Horns**](https://emojipedia.org/apple/ios-6.0/angry-face-with-horns "Angry Face with Horns on Apple iOS 6.0 – Emojipedia") devil emoji.

For the original set, the only time the **face** changes form is for the [😱 **Face Screaming in Fear**](https://emojipedia.org/apple/ios-6.0/face-screaming-in-fear "Face Screaming in Fear on Apple iOS 6.0 – Emojipedia") emoji. It takes the shape of the [👽 **Alien**](https://emojipedia.org/apple/ios-6.0/alien "Alien on Apple iOS 6.0 – Emojipedia") emoji, however, its anatomy remains the same.

### Emoji Expression Anatomy

**Expressions** are built on top of the **face** anatomy.

![](/public/photos/spaceboy3000/emoji-anatomy.png "Emoji Expression Anatomy Diagram, Alfred R. Duarte 2025")

An emoji **expression** consists of `5` layers:

1. **Accessories**
2. **Eyebrows**
3. **Eyes**
4. **Mouth**
5. **Face**

**Expressions** reuse a set of _anatomy_, and combine other emoji _anatomy_ to create unique **expressions**. Many _eyebrows_, _eyes_, & _mouths_ are shared across multiple emoji.

![_Selection of Emoji with Reused Anatomy, **2022**_](/public/photos/spaceboy3000/emoji-closeup-reused-anatomy.png "Selection of Emoji with Reused Anatomy, Alfred R. Duarte 2022")

## Dissection & Outlines

My technique for creating these emoji is purely **vector-based**.

Everything is built out of **shape layers** with **gradients**. There are **_no_** _layer effects_ or _masks_ used in this project.

![_Smiling Face Emoji Vector+Outlines & Outlines Dissection, **2025**_](/public/photos/spaceboy3000/emoji-dissection-smiling.png "Smiling Face Emoji Dissection, Alfred R. Duarte 2025")

I didn't use any brush-tricks or vectorization tools. Everything was either built from **geometric shapes** or by using the **pen tool**.

![_Hundred Points Emoji Outlines, **2025**_](/public/photos/spaceboy3000/emoji-outlines-hundred.png "Hundred Points Emoji Outlines, Alfred R. Duarte 2025")

There may be inconsistencies in the vertex placements on the outlines above due to the technique used to render the vertices. I split the line into individual paths, then used `open square` **line-ends** to create the vertices.

## Comparisons & Close-ups

Below are some close-up comparisons of my emoji with **Apple**'s iOS 6.0 emoji.

A small reminder that my emoji are **vector-based** and **Apple**'s are **pixel-based**.

![](/public/photos/spaceboy3000/emoji-comparison-alien.png "Alien Emoji Comparison; Apple 2012, Alfred R. Duarte 2022")

![](/public/photos/spaceboy3000/emoji-comparison-crying.png "Crying Emoji Comparison; Apple 2012, Alfred R. Duarte 2022")

![](/public/photos/spaceboy3000/emoji-comparison-angry.png "Enraged Emoji Comparison; Apple 2012, Alfred R. Duarte 2022")

![](/public/photos/spaceboy3000/emoji-comparison-finger.png "Index Pointing Up Emoji Comparison; Apple 2012, Alfred R. Duarte 2022")

![](/public/photos/spaceboy3000/emoji-comparison-party.png "Party Popper Emoji Comparison; Apple 2012, Alfred R. Duarte 2022")

![_Ghost Emoji Close-up, **2022**_](/public/photos/spaceboy3000/emoji-closeup-ghost.png "Ghost Emoji Close-up, Alfred R. Duarte 2022")

![_Bomb Emoji Close-up, **2022**_](/public/photos/spaceboy3000/emoji-closeup-bomb.png "Bomb Emoji Close-up, Alfred R. Duarte 2022")

![_Smiling Face with Sunglasses Emoji Close-up, **2022**_](/public/photos/spaceboy3000/emoji-closeup-sunglasses.png "Smiling Face with Sunglasses Emoji Close-up, Alfred R. Duarte 2022")

## Side-by-Side Comparison

%[iOS 6.0 Emoji Grid, Apple 2012](/public/photos/spaceboy3000/ios6-emoji-grid-apple.png)
%[iOS 6.0 Emoji Grid, Alfred 2022](/public/photos/spaceboy3000/ios6-emoji-grid-alfred.png)

> Use the slider above to compare my emoji (_left_) against the original **Apple iOS 6.0** emoji (_right_).

For only using _vector shapes_ & _gradients_–I think I got pretty close!

Looking back at them now, I see a few small things besides shading differences:

- The teeth should take on a shadow from the top lip;
- The devils' eyebrows & eyes should be touching;
- And the flushed-blue faces should have dark-blue eyebrows.

_Soo_ close! 😄

The sizes of the original **Apple** 😩 & 😫 emoji are slightly larger than all others for some reason–likely to accommodate their larger mouths. I left mine intentionally all an identical size.

In all, this was a fun project! My goal wasn't to perfectly recreate the original emoji, just to see how far pure-vector could go. In the end, I learned a lot from **Apple**'s emoji design and got to see how far I could push my vector & gradient skills. 🖼️

## Resources

- [**Apple Color Emoji (iOS 6.0)**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0 "Apple Color Emoji (iOS 6.0) – Emojipedia")

##### Apple Color Emoji (iOS 6.0) Referenced

- [☀️ **Sun**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/sun "Sun on Apple iOS 6.0 – Emojipedia")
- [😮 **Face with Open Mouth**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/face-with-open-mouth "Face with Open Mouth on Apple iOS 6.0 – Emojipedia")
- [👽 **Alien**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/alien "Alien on Apple iOS 6.0 – Emojipedia")
- [😭 **Loudly Crying Face**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/loudly-crying-face "Loudly Crying Face on Apple iOS 6.0 – Emojipedia")
- [😡 **Enraged Face**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/pouting-face "Pouting Face on Apple iOS 6.0 – Emojipedia")
- [☝️ **Index Pointing Up**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/index-pointing-up "Index Pointing Up on Apple iOS 6.0 – Emojipedia")
- [🎉 **Party Popper**, _Emojipedia_](https://emojipedia.org/apple/ios-6.0/party-popper "Party Popper on Apple iOS 6.0 – Emojipedia")

---

#### `📚` **_`Book a meeting to view the .afdesign files.` [`➔`](mailto:alfred.r.duarte@gmail.com)_**

[**alfred.r.duarte@gmail.com**](mailto:alfred.r.duarte@gmail.com "Gmail – Alfred R. Duarte")
