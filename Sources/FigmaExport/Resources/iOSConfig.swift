let iosConfigFileContents = #"""
---
figma:
  # Identifier of the file containing light color palette, icons and light images. To obtain a file id, open the file in the browser. The file id will be present in the URL after the word file and before the file name.
  lightFileId: shPilWnVdJfo10YF12345
  # [optional] Identifier of the file containing dark color palette and dark images.
  darkFileId: KfF6DnJTWHGZzC912345
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
    useSingleFile: false
    # [optional] If useSingleFile is true, customize the suffix to denote a dark mode color. Defaults to '_dark'
    darkModeSuffix: '_dark'
  # [optional]
  icons:
    # [optional] Name of the Figma's frame where icons components are located
    figmaFrameName: Icons
    # [optional] RegExp pattern for icon name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^(ic)_(\d\d)_([a-z0-9_]+)$' # RegExp pattern for: ic_24_icon_name, ic_24_icon
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'icon_$2_$1'
    # [optional] Extract light and dark mode icons from the lightFileId specified in the figma params. Defaults to false
    useSingleFile: false
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
    useSingleFile: false
    # [optional] If useSingleFile is true, customize the suffix to denote a dark mode icons. Defaults to '_dark'
    darkModeSuffix: '_dark'
  # [optional]
  typography:
    # [optional] RegExp pattern for text style name validation before exporting. If a name contains "/" symbol it will be replaced by "_" before executing the RegExp
    nameValidateRegexp: '^[a-zA-Z0-9_]+$' # RegExp pattern for: h1_regular, h1_medium
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'font_$1'

# iOS export parameters
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
                         
  # [optional] Parameters for exporting colors
  colors:
    # How to export colors? Use .xcassets and UIColor extension (useColorAssets = true) or extension only (useColorAssets = false)
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
    groupUsingNamespace: false

  # [optional] Parameters for exporting icons
  icons:
    # Image file format: pdf or svg
    format: pdf
    # Name of the folder inside Assets.xcassets where to place icons (.imageset directories)
    assetsFolder: Icons
    # Icon name style: camelCase or snake_case
    nameStyle: camelCase
    # [optional] An array of icon names that will supports Preseve Vecotor Data
    preservesVectorRepresentation:
    - ic24TabBarMain
    - ic24TabBarEvents
    - ic24TabBarProfile
    # [optional] Absolute or relative path to swift file where to export icons (SwiftUI’s Image) for accessing from the code (e.g. Image.illZeroNoInternet)
    swiftUIImageSwift: "./Source/Image+extension_icons.swift"
    # [optional] Absolute or relative path to swift file where to generate extension for UIImage for accessing icons from the code (e.g. UIImage.ic24ArrowRight)
    imageSwift: "./Example/Source/UIImage+extension_icons.swift"

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
"""#
