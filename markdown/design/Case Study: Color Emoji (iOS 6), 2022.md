![_iOS 6-style Emoji Grid, **2022**_](/public/photos/spaceboy3000/ios6-emoji-grid.png)

# Case Study: Apple Color Emoji (iOS 6.0)

> **June 2022**

### `⚠️` **_`This article is under construction.`_**

### **_`Book a`[`meeting`](# "Calendly – Alfred R. Duarte")`to view the .afdesign files.` [`➔`](# "Calendly – Alfred R. Duarte")_**

- [**Secrets of Emoji Design**](#secrets-of-emoji-design)
- [**Anatomy of Emoji**](#anatomy-of-emoji)
- [**Dissection & Outlines**](#dissection-outlines)
- [**Comparisons & Close-ups**](#comparisons-close-ups)
- [**Side-by-Side Comparison**](#side-by-side-comparison)

I've always loved **Apple**'s [icon design](https://developer.apple.com/design/human-interface-guidelines/icons "Apple Human Interface Guidelines: Icons"). Their depth and precision is truly inspiring.

The set of original **iOS 6.0** emoji are timeless & iconic. Their style set the standard for emoji design.

I wanted to take a look and see how the original emoji were made. If you try to blow emoji up to a large size, you'll find they're just images. The [original designers have shared](https://blog.emojipedia.org/who-created-the-original-apple-emoji-set/ "Who Created The Original Apple Emoji Set? – Emojipedia") that they were digital paintings, but I wanted to see what I could do using vector alone.

Recently, I had just completed a similar [case study on pushing the limits of vector shapes & gradients for UI design](#). That project equipped me with very delicate _shading_ & _composition_ techniques using only vector. I wanted to see how those same techniques could apply to the depth & detail of emoji design.

**_All of the emoji I created in this project are purely vector-based._**

> _**Disclaimer**: I am **not affiliated** with Apple. Emoji reference images are **unmodified** and used for educational purposes only._

#### Tools used:

- [Affinity Designer](https://affinity.serif.com/en-us/designer/)

## Secrets of Emoji Design

![_[Sun](https://emojipedia.org/apple/ios-6.0/sun "Sun on Apple iOS 6.0 – Emojipedia") & [Surprised](https://emojipedia.org/apple/ios-6.0/face-with-open-mouth "Surprised Face with Open Mouth on Apple iOS 6.0 – Emojipedia") Emoji Overlap, **Apple Color Emoji (iOS 6.0) 2012**_](/public/photos/spaceboy3000/emoji-overlap-sun-surprised.png)

_Which came first_–the **_sun_** or the **_surprised face_**?

I was browsing the original emoji set looking for strong reference candidates. I noticed the shading for the body of the **sun** emoji was nearly identical to the body of the **emoji face**/**head**.

Rather than attempt an emotive emoji, I decided to use the **sun** emoji as my starting reference for breaking down the anatomy of the **emoji face**.

While I can't unmask specifics around my techniques, I can share about the principles I used and my process behind breaking down **Apple**'s emoji design.

### Light & Scene

Apple designers carry a strong understanding of _physical-based_ **light** & **scene composition**.

![](/public/photos/spaceboy3000/emoji-scene-composition.png)

Emoji take on _studio-quality lighting_, likely from a **3-point lighting setup** (not pictured).

A strong **light source** seems to be positioned vertically above the emoji subject, casting a strong _highlight_ on objects. Fill & back lighting are used to create a sense of depth, reducing contrasting shadows while maintaining vibrancy.

### Object Composition

As previously mentioned, emoji were originally digital paintings. Objects don't really follow [shape-building principles](https://helpx.adobe.com/illustrator/using/building-new-shapes-using-shape.html#shape-builder "Build new shapes with Shaper and Shape Builder tools – Adobe Illustrator Help") like we're used to seeing from **Apple**'s iconography.

With that said, their emoji are still highly compositional, with mostly-geometric shapes used to build objects.

![](/public/photos/spaceboy3000/emoji-dissection-sun.png)

**Apple** designers likely **painted onto flat shapes** to create depth and simulate light. They likely used a combination of **layer effects** as well as the trusty **brush tool** to create the final look.

My own technique reuses shape layers with gradients to construct depth out of as few vertices as possible. This to offload processing required by the **CPU** and relying on shaders to push intensive rendering work on the **GPU**.

### Edges, Faces, & Bodies

In typical **Apple** style, much focus is placed on **edge definition**. **Edges** capture _shape_ & _form_ to create their signature sense of depth.

**Edges** & **faces** catch light to build _definition_.

**Faces** mold form and express _physicality_, like material-based properties.

**Bodies** cast shadow and fill light-space for a sense of _volume_.

![_Sun Emoji Close-up, **2022**_](/public/photos/spaceboy3000/emoji-closeup-sun.png)

### Blending & Gradients

The key to achieving the classic **Apple** emoji look is **blending**.

## Anatomy of Emoji

Emoji rely heavily on strong principles of **light** & **blending**.

Lines take shape and mold form into the face base. Gradients capture depth from the light cast on the face surface.

![](/public/photos/spaceboy3000/emoji-anatomy.png)

![](/public/photos/spaceboy3000/emoji-face-anatomy.png)

## Dissection & Outlines

![](/public/photos/spaceboy3000/emoji-dissection-smiling.png)

![](/public/photos/spaceboy3000/emoji-outlines-hundred.png)

There may be inconsistencies in the vertex placements on the outlines due to the technique used to render the vertices. I split the line into individual paths, then used `open square` **line-ends** to create the vertices.

## Comparisons & Close-ups

![](/public/photos/spaceboy3000/emoji-comparison-alien.png)

![](/public/photos/spaceboy3000/emoji-comparison-crying.png)

![](/public/photos/spaceboy3000/emoji-comparison-angry.png)

![](/public/photos/spaceboy3000/emoji-comparison-finger.png)

![](/public/photos/spaceboy3000/emoji-comparison-party.png)

![](/public/photos/spaceboy3000/emoji-closeup-sunglasses.png)

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

The sizes of the original Apple 😩 & 😫 emoji are slightly larger than all others for some reason–likely to accommodate their larger mouths. I left mine intentionally all an identical size.

## Resources

- [Apple Color Emoji (iOS 6.0), _Emojipedia_](https://emojipedia.org/apple/ios-6.0 "Apple Color Emoji (iOS 6.0) – Emojipedia")
