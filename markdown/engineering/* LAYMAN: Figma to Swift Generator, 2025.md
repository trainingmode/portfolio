![_**LAYMAN** Logo, **2025**_](/public/photos/layman/layman-logo.png "LAYMAN Logo, Alfred R. Duarte 2025")

> Engineering & Design

# **LAYMAN** — Figma to SwiftUI Generator

> **August 2024 — Present**

**LAYMAN** is a [Figma Dev Mode](https://www.figma.com/plugin-docs/working-in-dev-mode/ "Working in Dev Mode | Plugin API | Figma") plugin that converts [Figma Frames](https://www.figma.com/plugin-docs/api/FrameNode/ "FrameNode | Plugin API | Figma") into [SwiftUI View](https://developer.apple.com/documentation/swiftui/view "View | Apple Developer Documentation") code.

***Below is a fork of the original project README.***

---

- [**Render as a Single File**](#render-as-a-single-file)
- [**Generator Tags**](#generator-tags)
- [**SwiftUI Control Transformations**](#swiftui-control-transformations)
- [**Generator Settings**](#generator-settings)
- [**Changes & Additions**](#changes--additions)
- [**How to Build**](#how-to-build)
- [**Upcoming Fixes**](#upcoming-fixes)
- [**Upcoming Features**](#upcoming-features)

## Render as a Single File

The generator can be configured to render all code as a single file. The file can be copy-pasted into a single Swift file that should compile without any additional dependencies.

This is useful for testing and observing components during design.

The following generator settings must be set:

- **Effect Style Output** `Render in Place`
- **Custom Fonts** `System (dynamic)`
- **Text Style Output** `Render in Place`
- **Component Instances** `Deep Render`
- **Node Parent** `Crawl Document`
- **Render Mode** `Preview`
- **Vector Images** `Render in Place`
- **Figma Variables** `Render in Place`

## Generator Tags

Generator tags can be used to define custom behaviours, properties, or conversions for a layer.

Tags are denoted by `{}` and are placed at the end of a layer name.

**_Syntax:_**

### `{tag props}`

- **`{}`** Denotes a generator tag.

- **`tag`** The name of the tag.

- **`props`** A comma-separated list of properties for the tag.

  - A colon separates a property name & value.
  - Strings are wrapped in double quotes.

_Example:_

```
Layer Name {geo name: geometryScreen, maxWidth}
```

---

### **`{aspect}`**

> _Alts:_ **`{aspectRatio}`**

> _Props:_
>
> - **`mode`** (_Optional_) The sizing mode, either `fit` or `fill`. Default is `fill`.
> - **`ratio`** (_Optional_) The ratio, as a string. Ex: `16:9`

Aspect Ratio.

Applies an `.aspectRatio()` modifier to the view.

If `mode` is set to `fit`, the aspect ratio is maintained while fitting the view within the frame. If `mode` is set to `fill`, the aspect ratio is maintained while filling the frame.

If `ratio` is set, a custom aspect ratio is used. Otherwise the aspect ratio of the frame is used.

---

### **`{convert}`**

> _Alts:_ **`{converter}`**

> _Props:_
>
> - **`view`** The name of the view.
> - **`props`** (_Optional_) Include the properties of the original view.
> - **`children`** (_Optional_) Include the children of the layer.
> - **`mod`** (_Optional_) Include the modifiers for the layer.
> - **`context`** (_Optional_) The context available within the view.
> - **`params`** (_Optional_) A string to render as the view's parameters.

Custom View Conversion.

Converts the layer to a custom defined view.

Only the custom `view` name is included if no additional parameters are set.

If `props` is present, the properties of the original view are included in the view. For text layers, this is the text content.

If `children` is present, the children of the layer are included in the view.

If `mod` is present, the modifiers for the layer are included in the view.

If `context` is set, the custom context will be made available within the view.

If `params` is set, the string is rendered as the view's parameters.

If a layer name contains more than one `{convert}` tag, only the first tag is considered.

---

### **`{geo}`**

> _Alts:_ **`{geometry}`**

> _Props:_
>
> - **`name`** (_Optional_) Custom name for the geometry.
> - **`maxWidth`** (_Optional_) Use the width of the geometry for the maximum width.
> - **`maxHeight`** (_Optional_) Use the height of the geometry for the maximum height.

Geometry Reader.

Wraps the view in a `GeometryReader`.

The size of the geometry is used in place of any `fill` sizing properties.

If `maxWidth` is set, the width of the geometry is applied to the maximum size of the view. The same applies for `maxHeight`. Using both will use the full size of the geometry for the maximum size of the view. If neither is set, the geometry is ignored for sizing the view.

---

### **`{hide}`**

> _Alts:_ **`{hidden}`**

Hide Layer.

Remove the view & its children from rendering.

---

### **`{import}`**

> _Props:_
>
> - **`lib`** The name of the library to import.

Library Import.

If `Preview` mode is set, adds a library import to the top of the file.

---

### **`{mod}`**

> _Alts:_ **`{modifier}`**

> _Props:_
>
> - **`name`** The name of the modifier.
> - **`stack`** (_Optional_) The name of the modifier stack to apply the modifier to.
>   - **`pre`** Prerender.
>   - **`content`** Content & text.
>   - **`frame`** Sizing & padding.
>   - **`style`** View styling.
>   - **`layout`** Positionin.
>   - **`effect`** Effects.
>   - **`post`** Postrender.
> - **`stackPos`** (_Optional_) The position where the modifier should be placed in the stack.
>   - **`first`** Place the modifier at the beginning of the stack.
>   - **`last`** Place the modifier at the end of the stack.
>   - **`start`** Place the modifier at the beginning of the stack.
>   - **`end`** Place the modifier at the end of the stack.
> - **`props`** (_Optional_) A comma-separated list of properties to apply to the modifier.

View Modifier.

Applies a Modifier to the View.

If `modStack` is set, the modifier is applied to the named modifier stack. For example, `style` would apply the modifier to the same level as `.background()` & `.border()` modifiers. If no stack is found matching the name, the modifier is added to the `post` stack.

---

### **`{reader}`**

> _Props:_
>
> - **`geo`** (_Optional_) The name of the geometry to read from.
> - **`maxWidth`** (_Optional_) Use the width of the geometry for the maximum width of the view.
> - **`maxHeight`** (_Optional_) Use the height of the geometry for the maximum height of the view.

Read the size from a parent `GeometryReader`.

The size of the parent geometry is used in place of any `fill` sizing properties.

If `geo` is set, the geometry with the matching name is used. If no name is set, the closest parent geometry is used. If no geometry is found matching the name, the reader is ignored.

If `maxWidth` is set, the width of the geometry is applied to the maximum width of the view. The same applies for `maxHeight`. Using both or neither will use the full size of the geometry for the maximum size of the view.

---

### **`{safeArea}`**

> _Props:_
>
> - **`ignore`** The edges of the safe area that will be ignored.
>   - **`all`** (_Default)_ Ignore all edges.
>   - **`horizontal`** Ignore both leading & trailing edges.
>   - **`vertical`** Ignore both top & bottom edges.
>   - **`top`** Ignore the top edge.
>   - **`bottom`** Ignore the bottom edge.
>   - **`left`** Ignore the leading/left edge.
>   - **`right`** Ignore the trailing/right edge.

Ignore edges of the safe area.

Allows content to flow outside the bounds of the safe area.

`ignore` **_must_** be present. If set, the specified edges are ignored. If no edges are set, all edges are ignored.

---

### **`{scroll}`**

> _Alts:_ **`{scrollView}`**

> _Props:_
>
> - **`content`** (_Optional_) If present, wraps the **_content_** in a ScrollView.
> - **`axis`** (_Optional_) The axis along which scrolling happens. Default is the major axis of the layer.
>   - **`vertical`** Vertical scrolling.
>   - **`horizontal`** Horizontal scrolling.
>   - **`all`** Both vertical and horizontal scrolling.
> - **`showIndicators`** (_Optional_) Boolean value to show scroll indicators. Default is `true`.
> - **`hideBars`** (_Optional_) If present, hides the scroll bars. Overrides `showIndicators`.

Scroll View.

Wraps the view in a `ScrollView`.

If `content` is set, the **_content_** is wrapped in the scroll view.

---

### **`{view}`**

> _Props:_
>
> - **`name`** The name of the view.
> - **`context`** (_Optional_) The context available within the view.
> - **`params`** (_Optional_) A string to render as the view's parameters.

Custom View.

Wraps the layer in a custom defined view.

If `context` is set, the custom context will be made available within the view.

If `params` is set, the string is rendered as the view's parameters.

If a layer name contains more than one `{view}` tag, views are nested within each other. The first tag is the outermost view.

---

### **`{viewModel}`**

> _Props:_
>
> - **`name`** The name of the ViewModel property.
> - **`as`** (_Optional_) Defines the structure of the rendered property.
>   - **`var`** (_Default_) Render a variable.
>   - **`func`** Render a function.
> - **`type`** (_Optional_) The type of the ViewModel property. For functions, the return type.
> - **`value`** (_Optional_) The value of the ViewModel property. For functions, the function body.
> - **`params`** (_Optional_) The parameters of the ViewModel function.
> - **`prefix`** (_Optional_) A prefix to add to the ViewModel variable.

ViewModel Properties.

Adds a property to the ViewModel. Creates either a variable or a function.

This is useful for creating custom placeholders in the `ViewModel` panel. These placeholders can be used to manage the state of any element in the main view.

---

## SwiftUI Control Transformations

Layers names can be transformed into SwiftUI controls. For example, a layer named `Divider` will be exported as a SwiftUI `Divider` view.

> _Note: Component Instances are **not** transformed._

_Example:_

```swift
Accept Button
```

↓↓

```swift
Button(action: $viewModel.acceptButtonAction) {
  // Accept Button Layer
}
```

### **`Button`**

A layer name that contains `Button` will be exported as a SwiftUI `Button` view.

A custom action will be added to the `ViewModel` panel.

### **`Divider`**

A layer name that contains `Divider` will be exported as a SwiftUI `Divider` view.

If the layer contains auto layout, the divider will be exported with padding applied.

If the layer contains fixed sizing, the divider will be exported with a fixed size along the major axis of the parent view.

### **`Picker`**

A layer name that contains `Picker` will be exported as a SwiftUI `Picker` view.

The layer is transformed into a `Picker` view and children become selectable items. The name of the layer is used as the label for the `Picker`.

A custom selection binding, as an integer, will be added to the `ViewModel` panel. Item `1` is selected by default.

> _Tip: Wrap the `Picker` in a `Form` or `List` view to display the selection label._

### **`SecureField`**

A layer name that contains `SecureField` will be exported as a SwiftUI `SecureField` view.

If the layer is a text layer, the text content will be used as the placeholder text.

A custom text binding will be added to the `ViewModel` panel.

### **`Slider`**

A layer name that contains `Slider` will be exported as a SwiftUI `Slider` view.

A custom value binding will be added to the `ViewModel` panel.

### **`Spacer`**

A layer name that contains `Spacer` will be exported as a SwiftUI `Spacer` view.

### **`TextField`**

A layer name that contains `TextField` will be exported as a SwiftUI `TextField` view.

If the layer is a text layer, the text content will be used as the placeholder text.

A custom text binding will be added to the `ViewModel` panel.

### **`Toggle`**

A layer name that contains `Toggle` will be exported as a SwiftUI `Toggle` view.

A custom state variable will be added to the `ViewModel` panel.

---

## Generator Settings

### **Effects**

#### **Backdrop Blur Output**

Technique used to render backdrop blur effects.

- **`Material`** Render as SwiftUI Materials. Requires predefined blur types. System default.

  | Radius | Swift Material           |
  | ------ | ------------------------ |
  | `100`  | `.ultraThin` _(default)_ |
  | `200`  | `.thin`                  |
  | `300`  | `.regular`               |
  | `500`  | `.thick`                 |
  | `600`  | `.ultraThick`            |
  | `1000` | `.bar`                   |

- **`Modifier`** Render as a custom global modifier based on UIKit Materials. Requires predefined blur types.

  | Radius | UIKit Material                  |
  | ------ | ------------------------------- |
  | `0`    | `.extraLight` _(default)_       |
  | `1`    | `.light`                        |
  | `2`    | `.dark`                         |
  | `3`    | `.extraDark`                    |
  | `4`    | `.regular`                      |
  | `5`    | `.prominent`                    |
  | `6`    | `.systemUltraThinMaterial`      |
  | `7`    | `.systemThinMaterial`           |
  | `8`    | `.systemMaterial`               |
  | `9`    | `.systemThickMaterial`          |
  | `10`   | `.systemChromeMaterial`         |
  | `11`   | `.systemUltraThinMaterialLight` |
  | `12`   | `.systemThinMaterialLight`      |
  | `13`   | `.systemMaterialLight`          |
  | `14`   | `.systemThickMaterialLight`     |
  | `15`   | `.systemChromeMaterialLight`    |

- **`View`** Render as a custom view modifier. Allows for any blur radius amount. High accuracy, low performance.

#### **Effect Style Output**

How Figma Effect Styles are rendered.

- **`Modifier`** Render as a custom view modifier. The name of the effect style is used as the modifer name. Global style modifiers are generated in the `Effect Styles` panel.

- **`Render in Place`** Render the effect style in place. No global style modifiers are generated, and the effect style is rendered directly on the view.

#### **Materials on Shapes**

Swift Materials can be applied to shapes as either the background of the content area or as the shape fill.

- **`Content Background (default)`** Render materials as `.background()` modifiers. The material is applied to the entire content area of the shape.

- **`Shape Fill`** Render materials as `.fill()` modifiers. The material is applied to the shape fill.

### **Fonts**

#### **Custom Fonts**

Allow custom fonts to be exported, or use system fonts. The system font can match to constants or take on dynamic sizes & styles from the design.

- **`Link by Name`** Use the name of the font in the design to match to a custom font.

- **`System Font (dynamic) (default)`** Use the system font for the platform as `.system()` modifiers with custom sizes matching the font size in the design.

- **`System Font (fixed)`** Match the system font constant nearest to the font size in the design.

#### **Font Weight Matching**

Font weights can be matched to system font weights or use the name of the font weight in the design (unsupported).

- **`Figma Variables (unsupported)`** Use the name of the font weight in the design as a font weight. Currently unsupported by the Figma API, as font style is used for both font style and font weight.

- **`System (default)`** Match the system font weight contstant to the font weight in the design.

#### **Letter Spacing Style**

iOS renders spacing in text by kerning characters. Figma render spacing in text by tracking characters.

- **`Kerning (iOS) (default)`** Translate the letter spacing to kerning.

- **`Tracking (Figma)`** Keep the letter spacing as tracking.

#### **Line Height**

Figma allows setting the line height, whereas iOS only natively supports spacing between lines.

- **`Keep Figma`** Keep the line height as set in Figma.

- **`Remove (default)`** Remove the line height. iOS will apply the default line height.

#### **System Font Size**

The iOS Dynamic Type system allows for text to be resized based on the user's preferred text size.

When `Custom Fonts` is set to **System**, this setting defines how to translate the font sizes in the design to the system font size.

- **`Large (default)`** Use the large system font size set.

#### **Text Style Output**

Text styles can be exported as custom view modifiers or rendered in place.

- **`Modifier (default)`** Render text styles as custom view modifiers. The name of the text style is used as the modifier name. Global style modifiers are generated in the `Text Styles` panel.

- **`Render in Place`** Render the text style in place. No global style modifiers are generated, and the text style is rendered directly on the view.

### **Generator**

#### **Component Instances**

Instances of components can be exported as a single component, or as a deep render of the component.

- **`Deep Render`** Deep render the component in place of the instance.

- **`Link by Name (default)`** Use the name of the component in the design as the name of a custom View. The custom View is then called in place of the instance.

#### **Error Output**

Choose whether to output errors in the console terminal. In the Figma Desktop app, `Menu Bar` > `Plugins` > `Development` > `Show/Hide Cconsole`.

- **`Show`** Show errors in the console terminal.

- **`Hide (default)`** Hide errors in the console terminal.

#### **Instance Layer Tags**

Layer Tags can be processed on Component Instances. This feature can be disabled, for example, when main components were already rendered with the tags.

- **`Enabled`** Process Layer Tags on Component Instances.

- **`Disabled (default)`** Do not process Layer Tags on Component Instances.

#### **Layer Tags**

Layer Tags are special tags that can be used to define custom behaviours or properties to a layer. Tags are denoted by `{}` and are placed at the end of a layer name.

- **`Enabled (strict)`** Enable Layer Tags. Tags must be correctly formatted/capitalized to be recognized. Unrecognized tags are ignored.

- **`Enabled (unstrict) (default)`** Enable Layer Tags. Formatting & capitalization of tags are ignored. Unrecognized tags are ignored.

- **`Disabled (faster)`** Disable Layer Tags.

#### **Node Parent**

By default, the Figma API does not provide the parent of the selected node. This setting allows the document to be crawled to determine the parent of the selected node. Very slow, as the entire document may be crawled.

- **`Crawl Document (default)`** Crawl the document to determine the parent of the selected node.

- **`Only Selected (faster)`** Only use the selected node as the topmost parent.

#### **Progress Bar**

The total amount used for the progress bar displayed in the console terminal. The progress bar is used to indicate the progress of the code generation process. In the Figma Desktop app, `Menu Bar` > `Plugins` > `Development` > `Show/Hide Cconsole`.

- **`1000`**

- **`500`**

- **`300`**

- **`100 (default)`**

- **`Disabled`**

#### **Render Mode**

The render mode determines how the code is generated in the main `SwiftUI` panel. The code can be rendered as a full preview, just a struct, or as only view code.

- **`Snippet`** Render only the view code.

- **`Struct`** Render view as a complete struct.

- **`Preview (default)`** Render the full preview for the struct.

#### **Vector Images**

Vector images can be rendered as `Path` views or linked as a custom view. Vectors are rendered in the `Vector Images` panel.

> _Note: Vector image render is very slow._

- **`Disabled (default)`** Do not render vector images.

- **`Link by Name`** Render the vector image in the `Vector Images` panel. The name of the vector image is used as the name of the custom view linked in the code.

- **`Render in Place`** Render each vector image as a `Path` view in the code. Potentially very slow.

### **METADATA**

#### **Component Descriptions**

Figma components may contain multiline descriptions. These descriptions can be exported as multiline comments in the output code.

- **`As Comments (default)`**

- **`Disabled`**

#### **Component Links**

Figma components may contain links to documentation, etc. These links can be exported as comments in the output code.

- **`As Comments (default)`**

- **`Disabled`**

#### **Component Set Names**

Figma components may be part of a component set. The name of the component set can be exported as a comment with each component variant in the output code.

- **`As Comments (default)`**

- **`Disabled`**

#### **Document Properties**

The entire document's properties can be exported as a single line JSON string in the `Document Properties` panel.

> _Note: This feature is currently in beta. Only the document ID can be exported. lol_

- **`Enabled (beta)`**

- **`Disabled (default)`**

#### **Layer Names**

Figma layers have names. These names can be exported as comments in the output code.

- **`As Comments (default)`**

- **`Disabled`**

#### **Layer Properties**

All properties of a layer can be exported as a single line JSON string in the output code.

- **`As Comments (default)`**

- **`Disabled`**

#### **Local Variables**

All variables local to the current document can be exported in the `Local Variables` panel.

> _Note: This feature is currently in beta. Only some variables can be exported._

- **`Enabled (beta)`**

- **`Disabled (default)`**

#### **Team Libraries**

Figma teams may have libraries shared across the team. All libraries present in the current document can be exported in the `Team Libraries` panel.

> _Note: This feature is currently in beta._

- **`Enabled (beta)`**

- **`Disabled (default)`**

### **SWIFTUI**

#### **Control Actions**

SwiftUI controls may contain actions. Placeholder action can be exported inline with the control or as a separate function in the `ViewModel` panel.

- **`Render in Place`** Render a placeholder action inline with the control.

- **`ViewModel (default)`** Render a placeholder action in the `ViewModel` panel.

#### **Duplicate Actions**

Two layers with identical names will produce ViewModel functions with identical names.

A number suffix can be added to any duplicates found.

- **`Index Instances (default)`** Append a number suffix to duplicate ViewModel functions.

- **`Marge (default)`** Merge duplicate ViewModel functions under a single name.

#### **SwiftUI Controls**

Layer names can be transformed into SwiftUI controls. For example, a layer named `Divider` will be exported as a SwiftUI `Divider` view.

- **`From Layer Name (default)`** Layer names are transformed into SwiftUI controls.

- **`Include Instances`** Component Instances will also be transformed into SwiftUI controls.

- **`Disabled`** Layer names are not transformed.

#### **ViewModel Actor**

SwiftUI provides concurrency with thread Actors. The `ViewModel` can be exported with the `@MainActor` global actor to ensure all operations are performed on the main thread.

- **`Basic Actor (default)`** Render the `ViewModel` panel as a basic actor.

- **`Main Actor`** Render the `ViewModel` panel with the `@MainActor` global actor.

### **Output**

#### **Dynamic Size**

Figma layers may contain dynamic sizing properties, such as `fill` width or height. The Figma API does not provide these properties. This setting allows for the dynamic sizing properties to be exported.

To use this feature, `Node Parent` must be set to `Crawl Document`.

- **`Always (default)`** Export dynamic sizing properties for any layer.

- **`Must Select Parent`** To export dynamic sizing properties, a parent containing auto layout must be selected.

#### **Image Aspect Ratio**

Images can be exported with their aspect ratio preserved. A `resizable` modifier is applied to the image view to respect the aspect ratio.

- **`Mesh from Frame`** Use the frame dimensions to create a resizable mesh.

- **`Preserve (default)`** Preserve the aspect ratio of the image and apply a resizable modifier.

#### **Layer Mask**

Figma layers may contain masks. Masking is not currently supported by the generator. Masks can be disabled from output or rendered as shapes for testing.

- **`Disable (default)`** Do not render masks.

- **`Render as Shape`** Render masks as shapes.

#### **No Layer Name**

When a layer contains no name, it must be given a unique name to be exported. This setting chooses the default name to be given to layers without a name.

- **`"FigmaLayer" (default)`**

- **`"Unnamed"`**

### **Transforms**

#### **Opacity Transforms**

Figma represents opacity as `33%` percentages. SwiftUI represents opacity as `0.33` decimals. This setting allows for the conversion of opacity values.

- **`Enabled (default)`** Convert opacity values to decimals.

- **`Keep Figma`** Keep opacity values as integer percentages.

#### **Variable Transforms**

Exact values used in Figma may not translate directly to SwiftUI. This setting enables transformations of variables to better match SwiftUI.

When a Figma variable is transformed, a `_mod` suffix is added to the variable name.

- **`Enabled (default)`** Apply transformations to variables.

- **`Keep Figma`** Keep variables as they are.

### **Variables**

#### **Duplicate Variables**

Figma variables may be used multiple times in a design. This setting allows for the identification of duplicate variables.

- **`Index Instances`**

- **`Merge (default)`**

#### **Figma Variables**

Figma variables used in the design are exported in a separate `Variables` panel. This setting enables the rendering the value of each variable in place of the variable name in the output code.

- **`Link by Name (default)`** Use the name of the variable in the design as the name of the variable in the code.

- **`Render in Place`** Render the value of the variable in place of the variable name in the code.

## Changes & Additions

This plugin is supplied with extended support for SwiftUI, as well as many fixes & opinionated changes.

- **Only Supports SwiftUI**

- **Updated Swift 6.0 Output** Generated code implements new features inctroduced in Swift 6, like updated Preview Providers.

- **Strict SwiftUI Compliance** Figma designs are translated as accurately as possible with code generated to the latest Swift 6.0 standard.

- **Generator Tags** Added support for parsing generator tags in Figma layer names. Tags can be used to define custom behaviours or properties to a layer. Tags are denoted by `{}` and are placed at the end of a layer name.

- **Accurate Layout Properties** Layout properties are now exported accurately. Frames take into account both horizontal & vertical alignment when translating to Swift. Responsive layout properties are now supported. Nested elements are now exported with responsive layout properties.

- **GeometryReader Support** Geometry Readers are now supported. Geometry Readers can be used to pass the size of a parent view to a child view. Geometry Readers are exported as `GeometryReader` views.

- **ScrollView Support** Scroll Views are now supported. Scroll Views can be used to scroll the inner content of a view. Scroll Views are exported as `ScrollView` views.

- **Basic Vector Rendering** Basic vector shapes are now supported. Vectors are exported as `Path` views. Rendering is expensive and may not be accurate/precise.

- **Correct Border Rendering** Border properties for frames are now exported correctly as `.border()` modifiers. Previously, they were exported as `.overlay()` modifiers containing `Rectangles` with strokes. If a frame has a nonuniform border, only then will the border will be exported as an overlay (as SwiftUI does not support individual border sizes on stacks).

  > _Note: To export as `.border()`, use a single **uniform border** size with **center alignment**._

- **Individual Border Sizes** Individual border sizes are now supported. SwiftUI does not support individual border sizes on stacks. Different techniques are used based on the border alignment.

  | Align   | Output          | Accuracy  |
  | ------- | --------------- | --------- |
  | Inside  | `.overlay()`    | 🔵 Medium |
  | Center  | `.overlay()`    | 🟡 Poor   |
  | Outside | `.background()` | 🟢 High   |

  For outside borders, a special technique using two `Rectangles` is used to simulate the border. This technique preserves rounded corners. A limitation is that certain uneven border sizes may not be supported, usually nonproportional increases to each side of the top & bottom anchors.

  ```ts
  /* Figma      =>    SwiftUI */
       1                 2
    ________          ========
  2 ||    || 2  =>  2 ||    || 2
    ||    ||          ||    ||
       0                 0
  // fig1. Unsupported border ⚠️
  ```

  ```ts
  /* Figma      =>    SwiftUI */
       2                 2
    ========          ========
  2 ||       0  =>  2 ||       0
    ||                ||
       0                 0
  // fig2. Supported border ✅
  ```

  > _Note: Only **Frame** & **Rectangle** layers currently support individual border output._

  > _Note: Dashed borders are not supported._

- **Correct Shape Fill Rendering** Shape fills are now exported correctly as `.fill()` modifiers. Previously, they were exported as `.background()` modifiers. `.fill()` fills a shape, while `.background()` is applied to the entire background boundaries of a view. `.background()` modifiers are now only used for frames. Shapes without a fill correctly have `.fill(Color.clear)` applied.

- **Text Style Rendering** Text Styles are now fully exported as Text View modifiers. Previously, only style snippets were provided. Text Views are exported with their associated custom modifier applied. Duplicate text styles are identified and exported as a single custom modifier.

- **Accurate System Fonts** System fonts are now accurately exported. Previously, system fonts were exported as custom fonts. System fonts are now exported as either a system font constant or as `.system()` modifiers for custom sizes. Custom fonts are still supported.

- **Effect Style Rendering** Effect Styles are now fully exported as View modifiers. Previously, only modifiers were provided. Effects are exported with their associated custom modifier applied. Duplicate effects are identified and exported as a single custom modifier.

- **Figma Component Support** Figma Components & Instances are now recognized and exported correctly. Instances can be deep rendered or exported using the layer name. Varients & Overrides are not yet supported.

- **SwiftUI Image Support** Image fills are now supported. Images are exported as `Image` views. The image source is set to the name matching the name of the asset available in the **Assets** section at the bottom of the Dev Mode sidebar. All image properties supplied by the Figma API are supported.

- **Figma Variables** Added full support for Figma variables inside generated code.

  - color
    - ✅ solid
    - ✅ gradient
    - ✅ image
    - ⏳ multiple fills
  - sizing
    - ✅ width
    - ✅ minWidth
    - ✅ maxWidth
    - ✅ height
    - ✅ minHeight
    - ✅ maxHeight
  - spacing
    - ✅ gap
      > _Note: SwiftUI applies default spacing, so a value will always be exported to maintain the gap present in your designs._
    - ✅ padding
      - ✅ left
      - ✅ right
      - ✅ top
      - ✅ bottom
  - border
    - ✅ color
    - ✅ width
      - ✅ all
      - ✅ left
      - ✅ right
      - ✅ top
      - ✅ bottom
    - ✅ alignment
      - ✅ center
      - ✅ inside
      - ✅ outside
  - ✅ corner radius
    > _Note: SwiftUI does not support individual corner radii._
  - typography
    - ✅ text styles
    - ✅ color
    - ✅ characters (text content)
    - ✅ font family
    - ✅ font size
    - ✅ font weight
    - ✅ font style
    - ✅ line height
    - ✅ letter spacing
      > _Note: SwiftUI has poor support for paragraph spacing._
  - ✅ opacity
  - effects
    - ✅ drop shadow
      - ✅ color
      - ✅ x
      - ✅ y
      - ✅ blur
      - ✅ spread
        > _Note: SwiftUI does not support drop shadow spread._
    - ✅ background blur
      - ✅ radius
    - ✅ layer blur
      - ✅ radius
    - ✅ effect styles
    - ⏳ multiple effects
      > _Note: Only a single instance of each effect type, per frame, is currently supported._

- **Figma Variable Output** Figma Variables are now collected and exported in a separate `Variables` sections, similar to the default Figma code snippet generator. This allows for easy access to variables used in the design.

- **Variable Transformations** Transformations for variables are now supported. For example, a shadow with identical size values will be twice as large on iOS as it is in Figma. Transformations are now applied to the definition of a variable constant (or when rendering variables in place).

- **SwiftUI Control Transformations** Layers names can be transformed into SwiftUI controls. For example, a layer named `Divider` will be exported as a SwiftUI `Divider` view.

- **ViewModel Rendering** Added support for constructing a ViewModel. The `ViewModel` panel contains the `ViewModel` struct, which can be used to manage the state of any SwiftUI Controls in the view.

- **Better Position Offsets** Absolute positions are now more accurately translated into offsets. Previously, position offsets were not calculated.

- **Background Blur Support** Background blur effects are now supported as 3 separate blur types. Using either Swift Materials, a custom global modifier based on UIKit Materials, or a custom view modifier. Swift & UIKit materials required predefined blur types, while the custom view modifier allows for any radius amount.

- **True Backdrop Blur Support** True backdrop blur effects are now supported thanks to [this](https://stackoverflow.com/a/73950386) ([code](https://gist.github.com/Rukh/0eeedcb99fe057d1dba00d426c3fa105)). A custom effect view is created and placed behind the rendered view, then the two views are wrapped in a `ZStack`. A second technique thanks to [this](https://medium.com/@edwurtle/blur-effect-inside-swiftui-a2e12e61e750) ([code](https://gist.github.com/edwurtle/98c33bc783eb4761c114fcdcaac8ac71)) can also be applied, though essentially mimics SwiftUI materials.

- **Swift Context Rendering** Support for contexts within SwiftUI views has been added. Contexts are used to pass values down the view hierarchy. For example, a `GeometryReader` context can be used to pass the size of a parent view to a child view.

- **Layer METADATA Output** Layer METADATA can now be rendered as comments in the output code. Supports layer names, component descriptions and links. Component Set Names are exported with their Variants. An entire layer's METADATA properties can be exported as a single line JSON string.

- **Parser Stack Improvements** The internal parser has been rewritten to support modifier groupings within the modifiers stack. As Swift is declarative, the order of modifiers is important. Modifier groups allow for high accuracy in the ordering of modifiers. Groups also allow for high precision in the placement of new modifiers within the stack.

- **Removed Auto Layout Inferral** To simplify renderer impl, the `Inferred Auto Layout` calculation was removed. You must manually add Auto Layout to a frame to get layout properties. If you are unsure of what this means, you are unaffected.

- **Future Proofing** The plugin has been rewritten to be more modular and extensible. Future updates will be easier to implement.

### Things to Note

- A Figma Frame that contains no nested children will be exported as a `Rectangle` with the frame's properties. The Figma API classifies this unique case as a `Shape` and not a `Frame`; there is no way to discern between the types. This is a limitation of the Figma API and not the plugin.

- Figma does not support variables for font weights. The Figma API uses the font style as both the font style and font weight. All font weight are conerted to their system font weight equivalent.

- A `SceneNode` in the Figma API is a generic class that represents a branch. It is a branch within the broader HAST structure of the Figma document. It is _not_ an object that can be rendered, as JSON for example.

- In the parser, the original `cloneNode()` function **_removes_** all references to Figma components. This will need to change to fully support Figma Components.

- The original `frameToRectangleNode()` function can be made optional.

also: in the interest of time lots of `any`. sorry mom.

## How to Build

`pnpm` is used as the package manager.

`turbo` is used as the build/package tool.

Use `pnpm run build:clean` to build the plugin.

### Distribute

1. Build the plugin.
   ```sh
   pnpm run build:clean
   ```
2. Grab the plugin from the `dist` folder.
   ```
   /apps/plugin/dist/
   ```
3. Copy the `manifest.json` into the `dist` folder.
4. Zip the `dist` folder.

## Upcoming Fixes

- Fix Spacer() issue for auto layout.

- Fix Capitialization for Instance Layer Names with special characters, ex: `"My Layer (not capitalized)"` → `MyLayernotCapitalized`.

- Vertical Sizing on Dividers. `height` becomes modifier name instead of `frame`?

## Upcoming Features

- ⏳ _`{size}` Layer Tag_

  - ex: `{size max-w: fill, max-h: fill}`

- ⏳ _`{params}` Layer Tag_

  - Replace View Properties with Custom Parameters.

- ⏳ _`{bind}` Layer Tag_

  - Create a `@Binding` property for the View.
  - name, type, value, preview.

- ⏳⏳ `safeAreaInset`

- ⏳⏳ _Generator Plugins_

- ⏳⏳⏳ _Figma Component Variants & Overrides_

  - Export variants as multiple components.
  - Export overrides as custom modifiers.

- ⏳⏳⏳⏳ _More Expressive SwiftUI Output_

- ⏳⏳⏳⏳ _Parser Cleanup_
