# FigmaExport configuration file

Argument `-i` or `-input` specifies path to `figma-export.yaml` file where all the properties stores: figma, ios, android, flutter.

If `figma-export.yaml` file is next to the `figma-export` executable file you can omit `-i` option.

 `./figma-export colors`

Specification of `figma-export.yaml` file with all the available options:

```yaml
---
figma:
  # [required] Identifier of the file containing light color palette, icons and light images. To obtain a file id, open the file in the browser. The file id will be present in the URL after the word file and before the file name.
  lightFileId: shPilWnVdJfo10YF12345
  # [optional] Identifier of the file containing dark color palette and dark images.
  darkFileId: KfF6DnJTWHGZzC912345
  # [optional] Identifier of the file containing light high contrast color palette.
  lightHighContrastFileId: KfF6DnJTWHGZzC912345
  # [optional] Identifier of the file containing dark high contrast color palette.
  darkHighContrastFileId: KfF6DnJTWHGZzC912345
  # [optional] Figma API request timeout. The default value of this property is 30 (seconds). If you have a lot of resources to export set this value to 60 or more to give Figma API more time to prepare resources for exporting.
  # timeout: 30

# [optional] Common export parameters
common:
  # [optional]
  colors:
    # [optional] RegExp pattern for color name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^([a-zA-Z_]+)$' # RegExp pattern for: background, background_primary, widget_primary_background
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'color_$1'
    # [optional] Extract light and dark mode colors from the lightFileId specified in the figma params. Defaults to false
    useSingleFile: true
    # [optional] If useSingleFile is true, customize the suffix to denote a dark mode color. Defaults to '_dark'
    darkModeSuffix: '_dark'
    # [optional] If useSingleFile is true, customize the suffix to denote a light high contrast color. Defaults to '_lightHC'
    lightHCModeSuffix: '_lightHC'
    # [optional] If useSingleFile is true, customize the suffix to denote a dark high contrast color. Defaults to '_darkHC'
    darkHCModeSuffix: '_darkHC'
  # [optional]
  variablesColors:
    # [required] Identifier of the file containing variables
    tokensFileId: shPilWnVdJfo10YF12345
    # [required] Variables collection name
    tokensCollectionName: Base collection
    # [required] Name of the column containing light color variables in the tokens table
    lightModeName: Light
    # [optional] Name of the column containing dark color variables in the tokens table
    darkModeName: Dark
    # [optional] Name of the column containing light high contrast color variables in the tokens table
    lightHCModeName: Contast Light
    # [optional] Name of the column containing dark high contrast color variables in the tokens table
    darkHCModeName: Contast Dark
    # [optional] Name of the column containing color variables in the primitive table. If a value is not specified, the default values ​​will be taken
    primitivesModeName: Collection_1
    # [optional] RegExp pattern for color name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^([a-zA-Z_]+)$'
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'color_$1'
  # [optional]
  icons:
    # [optional] Name of the Figma's frame where icons components are located
    figmaFrameName: Icons
    # [optional] RegExp pattern for icon name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^(ic)_(\d\d)_([a-z0-9_]+)$' # RegExp pattern for: ic_24_icon_name, ic_24_icon
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'icon_$2_$1'
    # [optional] Extract light and dark mode icons from the lightFileId specified in the figma params. Defaults to false
    useSingleFile: true
    # [optional] If useSingleFile is true, customize the suffix to denote a dark mode icons. Defaults to '_dark'
    darkModeSuffix: '_dark'
  # [optional]
  images:
    # [optional]Name of the Figma's frame where image components are located
    figmaFrameName: Illustrations
    # [optional] RegExp pattern for image name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^(img)_([a-z0-9_]+)$' # RegExp pattern for: img_image_name
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'image_$2'
    # [optional] Extract light and dark mode icons from the lightFileId specified in the figma params. Defaults to false
    useSingleFile: true
    # [optional] If useSingleFile is true, customize the suffix to denote a dark mode icons. Defaults to '_dark'
    darkModeSuffix: '_dark'
  # [optional]
  typography:
    # [optional] RegExp pattern for text style name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^[a-zA-Z0-9_]+$' # RegExp pattern for: h1_regular, h1_medium
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'font_$1'

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
  # [optional] Is Assets.xcassets located in a swift package? Default value is false.
  xcassetsInSwiftPackage: false
  # [optional] When `xcassetsInSwiftPackage: true` use this property to specify a resource bundle name for Swift packages containing Assets.xcassets (e.g. ["PackageName_TargetName"]). This is necessary to avoid SwiftUI Preview crashes.
  resourceBundleNames: []
  # [optional] Add @objc attribute to generated properties so that they are accessible in Objective-C. Defaults to false
  addObjcAttribute: false
  # [optional] Path to the Stencil templates used to generate code
  templatesPath: "./Resources/Templates"
  
  # [optional] Parameters for exporting colors
  colors:
    # How to export colors? Use .xcassets and UIColor/Color extension (useColorAssets = true) or UIColor/Color extension only (useColorAssets = false)
    useColorAssets: true
    # [required if useColorAssets: True] Name of the folder inside Assets.xcassets where to place colors (.colorset directories)
    assetsFolder: Colors
    # Color name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] Absolute or relative path to swift file where to export UIKit colors (UIColor) for accessing from the code (e.g. UIColor.backgroundPrimary)
    colorSwift: "./Sources/UIColor+extension.swift"
    # [optional] Absolute or relative path to swift file where to export SwiftUI colors (Color) for accessing from the code (e.g. Color.backgroundPrimary)
    swiftuiColorSwift: "./Source/Color+extension.swift"
    # [optional] If true and a color style name contains symbol "/" then "/" symbol indicates grouping by folders, and each folder will have the "Provides Namespace" property enabled. Defaults to `false`.
    groupUsingNamespace: true

  # [optional] Parameters for exporting icons
  icons:
    # Image file format: pdf or svg
    format: pdf
    # Name of the folder inside Assets.xcassets where to place icons (.imageset directories)
    assetsFolder: Icons
    # Icon name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] An array of icon names that will supports Preseve Vecotor Data. Use `- "*"` to enable this option for all icons.
    preservesVectorRepresentation:
    - ic24TabBarMain
    - ic24TabBarEvents
    - ic24TabBarProfile
    # [optional] Absolute or relative path to swift file where to export icons (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
    swiftUIImageSwift: "./Source/Image+extension_icons.swift"
    # [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing icons from the code (e.g. UIImage.ic24ArrowRight)
    imageSwift: "./Example/Source/UIImage+extension_icons.swift"
    # Asset render mode: "template", "original" or "default". Default value is "template".
    renderMode: default
    # Configure the suffix for filtering Icons and to denote a asset render mode: "default". 
    # It will work when renderMode value is "template". Defaults to nil.
    renderModeDefaultSuffix: '_default'
    # Configure the suffix for filtering Icons and to denote a asset render mode: "original". 
    # It will work when renderMode value is "template". Defaults to nil.
    renderModeOriginalSuffix: '_original'
    # Configure the suffix for filtering Icons and to denote a asset render mode: "template". 
    # It will work when renderMode value isn't "template". Defaults to nil.
    renderModeTemplateSuffix: '_template'

  # [optional] Parameters for exporting images
  images:
    # Name of the folder inside Assets.xcassets where to place images (.imageset directories)
    assetsFolder: Illustrations
    # Image name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] An array of asset scales that should be downloaded. The valid values are 1, 2, 3. The deafault value is [1, 2, 3].
    scales: [1, 2, 3]
    # [optional] Absolute or relative path to swift file where to export images (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
    swiftUIImageSwift: "./Source/Image+extension_illustrations.swift"
    # [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing illustrations from the code (e.g. UIImage.illZeroNoInternet)
    imageSwift: "./Example/Source/UIImage+extension_illustrations.swift"

  # [optional] Parameters for exporting typography
  typography:
    # [optional] Absolute or relative path to swift file where to export UIKit fonts (UIFont extension).
    fontSwift: "./Source/UIComponents/UIFont+extension.swift"
    # [optional] Absolute or relative path to swift file where to generate LabelStyle extensions for each style (LabelStyle extension).
    labelStyleSwift: "./Source/UIComponents/LabelStyle+extension.swift"
    # [optional] Absolute or relative path to swift file where to export SwiftUI fonts (Font extension).
    swiftUIFontSwift: "./Source/View/Common/Font+extension.swift"
    # Should FigmaExport generate UILabel for each text style (font)? E.g. HeaderLabel, BodyLabel, CaptionLabel
    generateLabels: true
    # Relative or absolute path to directory where to place UILabel for each text style (font) (Requred if generateLabels = true)
    labelsDirectory: "./Source/UIComponents/"
    # Typography name style: camelCase or snake_case
    nameStyle: camelCase

# [optional] Android export parameters
android:
  # Relative or absolute path to the `main/res` folder including it. The colors/icons/images will be exported to this folder
  mainRes: "./main/res"
  # [optional] The package name, where the android resource constant `R` is located. Must be provided to enable code generation for Jetpack Compose
  resourcePackage: "com.example"
  # [optional] Relative or absolute path to the code source folder including it. The typography for Jetpack Compose will be exported to this folder
  mainSrc: "./main/src/java"
  # [optional] Path to the Stencil templates used to generate code
  templatesPath: "./Resources/Templates"
  
  # Parameters for exporting colors
  colors:
    # [optional] The package to export the Jetpack Compose color code to. Note: To export Jetpack Compose code, also `mainSrc` and `resourcePackage` above must be set 
    composePackageName: "com.example"
  # Parameters for exporting icons
  icons:
    # Where to place icons relative to `mainRes`? FigmaExport clears this directory every time your execute `figma-export icons` command
    output: "figma-import-icons"
    # [optional] The package to export the Jetpack Compose icon code to. Note: To export Jetpack Compose code, also `mainSrc` and `resourcePackage` above must be set 
    composePackageName: "com.example"
  # Parameters for exporting images
  images:
    # Image file format: svg or png
    format: webp
    # Where to place images relative to `mainRes`? FigmaExport clears this directory every time your execute `figma-export images` command
    output: "figma-import-images"
    # Format options for webp format only
    # [optional] An array of asset scales that should be downloaded. The valid values are 1 (mdpi), 1.5 (hdpi), 2 (xhdpi), 3 (xxhdpi), 4 (xxxhdpi). The deafault value is [1, 1.5, 2, 3, 4].
    scales: [1, 2, 3]
    webpOptions:
      # Encoding type: lossy or lossless
      encoding: lossy
      # Encoding quality in percents. Only for lossy encoding.
      quality: 90
  # Parameters for exporting typography
  typography:
    # Typography name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] The package to export the Jetpack Compose typography code to. Note: To export Jetpack Compose code, also `mainSrc` and `resourcePackage` above must be set 
    composePackageName: "com.example"

# Flutter export parameters
flutter:
  # [optional] Parameters for exporting colors
  colors:
    # [optional] Template for code generation. Default is nil (internal templates are used).
    templatesPath: ~/myTemplates/
    # [optional] Output file for the colors. Defaults to %current_directory%/colors.dart
    outputFile: ~/work/myFlutterProject/modules/ui_kit/ui_colors.dart
    # [optional] Name for the generated class. Defaults to `Colors`.
    outputClassName: UiColors
    # [optional] If true, variations will be generated as properties of your `Colors` class. For example:
    # ```dart
    # class Colors {
    #   final Color light;
    #   final Color dark;
    #   ...etc..
    #   static const background = Colors(light: Color(0xFFFFFFFF), dark: Color(0xFF000000), ...);
    #   ...etc...
    # ```
    # Note: When `generateVariationsAsProperties` is true, all colors in your Figma file must have the same variations. For example, if one color has only a light variation and another has both light and dark variations, an error will occur.
    # If false, all colors and variations will be generated as separate `static const` declarations, with the variation name appended to the constant. For example:
    # ```dart
    # class Colors {
    #   final Color value;
    #   static const backgroundLight = Colors(Color(0xFFFFFFFF));
    #   static const backgroundDark = Colors(Color(0xFF000000));
    #   static const backgroundAccentLight = Colors(Color(0xFFCCCCCC));
    #   ...etc...
    # ```
    # Defaults to `true`.
    generateVariationsAsProperties: true

  # [optional] Parameters for exporting icons
  icons:
    # [optional] Template for code generation. Default is nil (internal templates are used).
    templatesURL: ~/myTemplates/
    # [optional] Output file for the generated code. Defaults to %current_directory%/icons.dart
    outputFile: ./lib/foundation/icons/my_icons.dart
    # [optional] Name for the generated class. Defaults to `Icons`.
    iconsClassName: MyIcons
    # [optional] Name for the base class with asset properties (light and dark Strings). Defaults to `IconAsset`.
    baseAssetClass: IconAsset
    # [optional] Folder to download all the icons to. Defaults to `%current_directory%/icons/`.
    iconsAssetsFolder: ./assets/icons/my_icons
    # [optional] Use svg.vec instead of svg? Defaults to false. Note: it will only change the extension of files, not actually convert them. To convert, you need to do an additional step after running figma-export:
    # ```bash
    # vector_graphics_compiler -i <file>
    # ```
    useSvgVec: true
    # [required] Path to the downloaded icons for code generation. It will be used in constants like this:
    # ```dart
    # static const icUserPhoto = IconAsset(
    #   light: '%relativeIconsPath%/ic_user_photo_light.svg',
    #   dark: '%relativeIconsPath%/ic_user_photo_dark.svg',
    # );
    # ```
    # Note: trailing slash ("/") is mandatory here.
    relativeIconsPath: icons/color_icons/

  # [optional] Parameters for exporting images
  images:
    # [optional] Template for code generation. Default is nil (internal templates are used).
    # templatesURL: ~/myTemplates/
    # [optional] Output file for the generated code. Defaults to %current_directory%/images.dart
    outputFile: ./lib/foundation/images/my_images.dart
    # [optional] Name for the generated class. Defaults to `Images`.
    imagesClassName: MyImages
    # [optional] Name for the base class with asset properties (light and dark strings). Defaults to `ImageAsset`.
    baseAssetClass: ImageAsset
    # [optional] Path to the base asset class file to use in import statement. Defaults to `image_asset.dart`.
    baseAssetClassFilePath: image_asset.dart
    # [optional] Folder to download all the images to. Defaults to `%current_directory%/images/`.
    imagesAssetsFolder: ./assets/images/my_images
    # [required] Path to the downloaded images for code generation. It will be used in constants like this:
    # ```dart
    # static const userPhoto = ImageAsset(
    #   light: '%relativeIconsPath%/user_photo_light.webp',
    #   dark: '%relativeIconsPath%/user_photo_dark.webp',
    # );
    # ```
    # Note: trailing slash ("/") is mandatory here.
    relativeImagesPath: assets/images/my_images/
    # [optional] An array of asset scales to download. Valid values are 1, 2, and 3. The default is [1, 2, 3].
    scales: [1, 2, 3]
    # [required] Image format: svg, png, or webp
    format: webp
    # [optional] Only applicable if the chosen format is webp
    webpOptions:
      # Encoding type: lossy or lossless
      encoding: lossy
      # Encoding quality in percent (only for lossy encoding).
      quality: 50
```
