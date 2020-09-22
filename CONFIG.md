# FigmaExport configuration file

Argument `-i` or `-input` specifies path to `figma-export.yaml` file where all the properties stores: figma, ios, android.

If `figma-export.yaml` file is next to the `figma-export` executable file you can omit `-i` option.

 `./figma-export colors`

Specification of `figma-export.yaml` file with all available options:

```yaml
---
figma:
  # Identifier of Figma file
  lightFileId: shPilWnVdJfo10YF12345
  # [optional] Identifier of Figma file for dark mode
  darkFileId: KfF6DnJTWHGZzC912345

# [optional] Common export parameters
common:
  colors:
    # RegExp pattern for color name validation before exporting 
    nameValidateRegexp: '^[a-zA-Z_]+$' # RegExp pattern for: background, background_primary, widget_primary_background
  icons:
    # RegExp pattern for icon name validation before exporting 
    nameValidateRegexp: '^(ic)_(\d\d)_([a-z0-9_]+)$' # RegExp pattern for: ic_24_icon_name, ic_24_icon
  images:
    # RegExp pattern for image name validation before exporting
    nameValidateRegexp: '^(img)_([a-z0-9_]+)$' # RegExp pattern for: img_image_name

# [optional] iOS export parameters
ios:
  # Path to xcodeproj
  xcodeprojPath: "./Example.xcodeproj"
  # Xcode Target containing resources and corresponding swift code
  target: "UIComponents"
  # Absolute or relative path to the Assets.xcassets directory
  xcassetsPath: "./Resources/Assets.xcassets"
  # Is Assets.xcassets located in the main bundle?
  xcassetsInMainBundle: true

  # Parameters for exporting colors
  colors:
    # Should be generate color assets instead of pure swift code
    useColorAssets: True
    # [required if useColorAssets: True] Name of the folder inside Assets.xcassets where to place colors (.colorset directories)
    assetsFolder: Colors
    # Color name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] Absolute or relative path to swift file where to export UIKit colors (UIColor) for accessing from the code (e.g. UIColor.backgroundPrimary)
    colorSwift: "./Sources/UIColor+extension.swift"
    # [optional] Absolute or relative path to swift file where to export SwiftUI colors (Color) for accessing from the code (e.g. Color.backgroundPrimary)
    swiftuiColorSwift: "./Source/Color+extension.swift"

  # Parameters for exporting icons
  icons:
    # Image file format: pdf or svg
    format: pdf
    # Name of the folder inside Assets.xcassets where to place icons (.imageset directories)
    assetsFolder: Icons
    # Icon name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] Enable Preserve Vector Data for specified icons
    preservesVectorRepresentation:
    - ic24TabBarMain
    - ic24TabBarEvents
    - ic24TabBarProfile
    # [optional] Absolute or relative path to swift file where to export icons (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
    swiftUIImageSwift: "./Source/Image+extension_icons.swift"
    # [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing icons from the code (e.g. UIImage.ic24ArrowRight)
    imageSwift: "./Example/Source/UIImage+extension_icons.swift"

  # Parameters for exporting images
  images:
    # Name of the folder inside Assets.xcassets where to place images (.imageset directories)
    assetsFolder: Illustrations
    # Image name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] Absolute or relative path to swift file where to export images (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
    swiftUIImageSwift: "./Source/Image+extension_illustrations.swift"
    # [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing illustrations from the code (e.g. UIImage.illZeroNoInternet)
    imageSwift: "./Example/Source/UIImage+extension_illustrations.swift"

  # Parameters for exporting typography
  typography:
    # [optional] Absolute or relative path to swift file where to export UIKit fonts (UIFont extension).
    fontSwift: "./Source/UIComponents/UIFont+extension.swift"
    # [optional] Absolute or relative path to swift file where to export SwiftUI fonts (Font extension).
    swiftUIFontSwift: "./Source/View/Common/Font+extension.swift"
    # Will FigmaExport generate UILabel for each text style (font) e.g. HeaderLabel, BodyLabel, CaptionLabel.
    generateLabels: true
    # Path to directory where to place UILabel for each text style (font) (Requred if generateLabels = true)
    labelsDirectory: "./Source/UIComponents/"

# [optional] Android export parameters
android:
  # Export path
  mainRes: "./main/res"
  # Parameters for exporting images
  images:
    # Image file format: svg or png
    format: png

```
### Figma properties 

* `figma.lightFileId` — Id of the file containing light color palette and dark images. To obtain a file id, open the file. The file id will be present in the URL after the word file and before the file name.
* `figma.darkFileId` — (Optional) Id of the file containing dark color palette and dark images.

### iOS properties
* `ios.xcodeprojPath` — Relative or absolute path to .xcodeproj file
* `ios.target` — Xcode Target containing resources and corresponding swift code
* `ios.xcassetsPath` — Relative or absolute path to directory `Assets.xcassets` where to export colors, icons and images.
* `ios.xcassetsInMainBundle` — Is Assets.xcassets located in the main bundle?
* `ios.colors.useColorAssets` — How to export colors? Use .xcassets and UIColor (useColorAssets = true) extension or extension only (useColorAssets = false)
* `ios.colors.assetsFolder` — Name of the folder inside `Assets.xcassets` where colors will be exported. Used only if `useColorAssets == true`.
* `ios.colors.nameStyle` — Color name style: camelCase or snake_case
* `ios.colors.colorSwift` — [optional] Absolute or relative path to swift file where to export UIKit colors (UIColor) for accessing from the code (e.g. UIColor.backgroundPrimary)
* `ios.colors.swiftuiColorSwift` — [optional] Absolute or relative path to swift file where to export SwiftUI colors (Color) for accessing from the code (e.g. Color.backgroundPrimary)
* `ios.icons.format` — Image file format. `svg` or `pdf`.
* `ios.icons.assetsFolder` — Name of the folder inside `Assets.xcassets` where icons will be exported.
* `ios.icons.nameStyle` — Icon name style: camelCase or snake_case
* `ios.icons.preservesVectorRepresentation` — An array of icon names that will supports Preseve Vecotor Data.
* `ios.icons.swiftUIImageSwift` — [optional] Absolute or relative path to swift file where to export icons (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
* `ios.icons.imageSwift` — [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing icons from the code (e.g. UIImage.ic24ArrowRight)
* `ios.images.assetsFolder` — Name of the folder inside `Assets.xcassets` where images will be exported.
* `ios.images.nameStyle` — Images name style: camelCase or snake_case
* `ios.images.swiftUIImageSwift` — [optional] Absolute or relative path to swift file where to export images (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
* `ios.images.imageSwift` — [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing illustrations from the code (e.g. UIImage.illZeroNoInternet)
* `ios.typography.fontSwift` - [optional] Absolute or relative path to swift file where to export UIKit fonts (UIFont extension).
* `ios.typography.swiftUIFontSwift` - [optional] Absolute or relative path to swift file where to export SwiftUI fonts (Font extension).
* `ios.typography.generateLabels` -  Should FigmaExport generate UILabel for each text style (font)? E.g. HeaderLabel, BodyLabel, CaptionLabel
* `ios.typography.labelsDirectory` - Relative or absolute path to directory where to place UILabel for each text style (font) (Requred if generateLabels = true)

### Android properties
* `android.path` — Relative or absolute path to the `main/res` folder including it. The colors will be exported to `./values/colors.xml` and `./values-night/colors.xml`.
