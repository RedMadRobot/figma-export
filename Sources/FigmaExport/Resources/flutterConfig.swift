let flutterConfigFileContents = #"""
---
figma:
  # Identifier of the file containing the light color palette, icons, and light images. To obtain a file ID, open the file in your browser. The file ID appears in the URL after the word 'file' and before the file name.
  lightFileId: shPilWnVdJfo10YF12345
  # [optional] Identifier of the file containing dark color palette and dark images.
  darkFileId: KfF6DnJTWHGZzC912345
  # [optional] Figma API request timeout. The default value is 30 seconds. If you have many resources to export, set this value to 60 or higher to give the Figma API more time to prepare the resources for export.
  # timeout: 30

# [optional] Common export parameters
common:
  # [optional]
  colors:
    # [optional] RegExp pattern for color name validation before exporting. If a name contains the "/" symbol, it will be replaced with "_" before applying the regular expression.
    nameValidateRegexp: '^([a-zA-Z_]+)$' # RegExp pattern for: background, background_primary, widget_primary_background
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'color_$1'
    # [optional] Extract light and dark mode colors from the `lightFileId` specified in the `figma` parameters section. Defaults to false
    useSingleFile: false
    # [optional] If useSingleFile is true, customize the suffix used to denote a dark mode color. Defaults to '_dark'
    darkModeSuffix: '_dark'
  # [optional]
  icons:
    # [optional] Name of the Figma frame that contains the icon components
    figmaFrameName: Icons
    # [optional] RegExp pattern for icon name validation before exporting. If a name contains the "/" symbol, it will be replaced with "_" before applying the regular expression.
    nameValidateRegexp: '^(ic)_(\d\d)_([a-z0-9_]+)$' # RegExp pattern for: ic_24_icon_name, ic_24_icon
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'icon_$2_$1'
    # [optional] Extract light and dark mode icons from the `lightFileId` specified in the `figma` parameters section. Defaults to false
    useSingleFile: false
    # [optional] If useSingleFile is true, customize the suffix used to denote dark mode icons. Defaults to '_dark'
    darkModeSuffix: '_dark'
  # [optional]
  images:
    # [optional] Name of the Figma frame that contains the image components
    figmaFrameName: Illustrations
    # [optional] RegExp pattern for image name validation before exporting. If a name contains the "/" symbol, it will be replaced with "_" before applying the regular expression.
    nameValidateRegexp: '^(img)_([a-z0-9_]+)$' # RegExp pattern for: img_image_name
    # [optional] RegExp pattern for replacing. Supports only $n
    nameReplaceRegexp: 'image_$2'
    # [optional] Extract light and dark mode images from the `lightFileId` specified in the `figma` parameters section. Defaults to false
    useSingleFile: false
    # [optional] If useSingleFile is true, customize the suffix used to denote dark mode icons. Defaults to '_dark'
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
    # [optional] Template for code generation. Default is nil (internal templates are used).
    # templatesPath: ~/myTemplates/
    # [optional] Output file for the colors. Defaults to %current_directory%/colors.dart
    # outputFile: ~/work/myFlutterProject/modules/ui_kit/ui_colors.dart
    # [optional] Name for the generated class. Defaults to `Colors`.
    # outputClassName: UiColors
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
    # generateVariationsAsProperties: true

  # [optional] Parameters for exporting icons
  icons:
    # [optional] Template for code generation. Default is nil (internal templates are used).
    # templatesURL: ~/myTemplates/
    # [optional] Output file for the generated code. Defaults to %current_directory%/icons.dart
    outputFile: ./lib/foundation/icons/my_icons.dart
    # [optional] Name for the generated class. Defaults to `Icons`.
    iconsClassName: MyIcons
    # [optional] Name for the base class with asset properties (light and dark Strings). Defaults to `IconAsset`.
    baseAssetClass: IconAsset
    # [optional] Folder to download all the icons to. Defaults to `%current_directory%/icons/`.
    iconsAssetsFolder: ./assets/icons/my_icons
    # [optional] Use svg.vec instead of svg? Defaults to false.
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
"""#
