let androidConfigFileContents = #"""
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
                                
# [optional] Android export parameters
android:
  # Relative or absolute path to the `main/res` folder including it. The colors/icons/imags will be exported to this folder
  mainRes: "./main/res"
  # [optional] The package name, where the android resource constant `R` is located. Muste be provided to enable code generation for Jetpack Compose
  resourcePackage: "com.example"
  # [optional] Relative or absolute path to the code source folder including it. The typography for Jetpack Compose will be exported to this folder
  mainSrc: "./main/src/java"
  
  # Parameters for exporting colors
  colors:
    # [optional] The package to export the Jetpack Compose color code to. Note: To export Jetpack Compose code, also `mainSrc` and `resourcePackage` above must be set 
    composePackageName: "com.example"
    # [optional] File name for XML file with exported colors (default is "colors.xml")
    xmlOutputFileName: "colors.xml"
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

"""#
