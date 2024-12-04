let flutterConfigFileContents = #"""
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

# Flutter export parameters
flutter:
  # [optional] Parameters for exporting colors
  colors:
    # [optional] Template for codegen. Default is nil (uses internal templates).
    # templatesPath: ~/myTemplates/
    # [optional] Output file for the colors. Defaults to %current_directory%/colors.dart
    # outputFile: ~/work/myFlutterProject/modules/ui_kit/ui_colors.dart
    # [optional] Name for the generated class. Defaults to `Colors`.
    # outputClassName: UiColors
    # [optional] If `true`, it will generate variations as a properties of your `Colors` class, for example:
    # ```dart
    # class Colors {
    #   final Color light;
    #   final Color dark;
    #   ...etc..
    #   static const background = Colors(light: ..., dark: ..., ...);
    #   ...etc...
    # ```
    # Note: for this case (`generateVariationsAsProperties: true`), all the colors in your Figma must have the same variations (for example, if one color has only light variation and another color has light and dark variations, this will result in error).
    # If `false`, it will generate all the colors and variations as separate `static const`s, appending the variation name to the const. For example:
    # ```dart
    # class Colors {
    #   final Color value;
    #   static const backgroundLight = Colors(Color.fromARGB(...));
    #   static const backgroundDark = Colors(Color.fromARGB(...));
    #   static const backgroundAccentLight = Colors(Color.fromARGB(...));
    #   ...etc...
    # ```
    # Defaults to `true`.
    # generateVariationsAsProperties: true

  # [optional] Parameters for exporting icons
  icons:

  # [optional] Parameters for exporting images
  images:

  # [optional] Parameters for exporting typography
  typography:
"""#
