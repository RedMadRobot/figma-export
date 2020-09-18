# FigmaExport

<img src="images/logo.png"/><br/>

[![SPM compatible](https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat)](https://swift.org/package-manager)
[![GitHub license](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://github.com/RedMadRobot/Catbird/blob/master/LICENSE)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/FigmaExport.svg)](https://cocoapods.org/pods/FigmaExport)

Command line utility to export colors, typography, icons and images from Figma to Xcode / Android Studio project.
* color - Figma's color style
* typography - Figma's text style
* icon — Figma's component with small black vector image
* image — Figma's components with colorized image (Light/Dark)

The utility supports Dark Mode and Swift UI.

Why we've developed this utility:
* Figma doesn't support exporting colors and images to Xcode / Android Studio. Manual export takes a long time.
* For easy sync of the component library with the code

Articles:
* [[habr.com] FigmaExport: как автоматизировать экспорт UI-Kit из Figma в Xcode и Android Studio проекты](http://habr.com/ru/company/redmadrobot/blog/514118/)

Table of Contents:
- [Features](#features)
- [Result](#result)
  - [iOS](#ios)
  - [Android](#android)
- [Installation](#installation)
  - [Manual](#manual)
  - [Homebrew](#homebrew)
  - [CocoaPods + Fastlane](#cocoapods--fastlane)
- [Usage](#usage)
  - [Arguments](#arguments)
  - [Figma properties](#figma-properties)
  - [iOS properties](#ios-properties)
  - [Android properties](#android-properties)
  - [Exporting Typography](#exporting-typography)
- [Design requirements](#design-requirements)
- [Example iOS project](#example-ios-project)
- [Contributing](#contributing)
- [License](#license)
- [Feedback](#feedback)
- [Authors](#authors)

## Features

* Export light & dark color palette directly to Xcode / Android studio project
* Export icons to Xcode / Android Studio project 
* Export images to Xcode / Android Studio project
* Export text styles to Xcode project
* Supports Dark Mode
* Supports SwiftUI and UIKit

> Exporting icons and images works only for Professional/Organisation Figma plan because FigmaExport use *Shareable team libraries*.

## Result

### iOS

#### Colors

When your execute `figma-export colors` command `figma-export` exports colors from Figma directly to your Xcode project to the Assets.xcassets folder.

Figma light | Figma dark | Xcode
------------ | ------------- | -------------
<img src="images/figma_colors.png" width="229"/> | <img src="images/figma_colors_dark.png" width="229"/> | <img src="images/xcode.png" width="500"/>

Additionally the following Swift file will be created to use colors from the code.

```swift
 import UIKit
 
 extension UIColor {
    static var backgroundSecondaryError: UIColor { return UIColor(named: #function)! }
    static var backgroundSecondarySuccess: UIColor { return UIColor(named: #function)! }
    static var backgroundVideo: UIColor { return UIColor(named: #function)! }
    ...
 }

```

For SwiftUI the following Swift file will be created to use colors from the code.

```swift
 import SwiftUI
 
 extension Color {
    static var backgroundSecondaryError: Color { return Color(#function) }
    static var backgroundSecondarySuccess: Color { return Color(#function) }
    static var backgroundVideo: Color { return Color(#function) }
    ...
 }

```

If you set option `useColorAssets: False` in the configuration file, then will be generated code like this:
```swift
import UIKit

extension UIColor {
    static var primaryText: UIColor {
        if #available(iOS 13.0, *) {
            return UIColor { traitCollection -> UIColor in
                if traitCollection.userInterfaceStyle == .dark {
                    return UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
                } else {
                    return UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
                }
            }
        } else {
            return UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        }
    }
    static var backgroundVideo: UIColor {
        return UIColor(red: 0.467, green: 0.012, blue: 1.000, alpha: 0.500)
    }
}
```

#### Icons

Icons will be exported as PDF or SVG files with `Template Image` render mode.

<img src="images/icons.png" width="500"/>

Additionally the following Swift file will be created to use icons from the code.

```swift
import UIKit

extension UIImage {
    static var ic16Notification: UIImage { return UIImage(named: #function)! }
    static var ic24ArrowRight: UIImage { return UIImage(named: #function)! }
    static var ic24Close: UIImage { return UIImage(named: #function)! }
    static var ic24Dots: UIImage { return UIImage(named: #function)! }
    ...
}
```

For SwiftUI the following Swift file will be created to use images from the code.

```swift
import SwiftUI

extension Image {
    static var ic16Notification: Image { return Image(#function) }
    static var ic24Close: Image { return Image(#function) }
    static var ic24DropdownDown: Image { return Image(#function) }
    static var ic24DropdownUp: Image { return Image(#function) }
    ...
}
...
VStack {
  Image.ic24Close
  Image.ic24DropdownDown
}
...
```

#### Images

Images will be exported as PNG files the same way.

<img src="images/images.png" width="500"/>

Additionally the following Swift file will be created to use images from the code.

```swift
import UIKit

extension UIImage {
    static var illZeroEmpty: UIImage { return UIImage(named: #function)! }
    static var illZeroNetworkError: UIImage { return UIImage(named: #function)! }
    static var illZeroServerError: UIImage { return UIImage(named: #function)! }
    ...
}
```

For SwiftUI a Swift file will be created to use images from the code.

#### Typography

When your execute `figma-export typography` command `figma-export` generates 3 files:
1. `UIFont+extension.swift` extension for UIFont that declares your custom fonts. Use these fonts like this `UIFont.header()`, `UIFont.caption1()`.
2. `LabelStyle.swift` struct for generating attributes for NSAttributesString with custom lineHeight and tracking (letter spacing).
3. `Label.swift` file that contains base Label class and class for each text style. E.g. HeaderLabel, BodyLabel, Caption1Label. Specify these classes in xib files on in code.

Example of these files:
- [./Example/UIComponents/Source/Label.swift](./Example/UIComponents/Source/Label.swift)
- [./Example/UIComponents/Source/LabelStyle.swift](./Example/UIComponents/Source/LabelStyle.swift)
- [./Example/UIComponents/Source/UIFont+extension.swift](./Example/UIComponents/Source/UIFont+extension.swift)

### Android

Colors will be exported to `values/colors.xml` and `values-night/colors.xml` files.

Icons will be exported to `drawable` directory as vector xml files.

Images will be exported to `drawable` and `drawable-night` directory as vector xml files.

## Installation

 Before installation you must provide Figma personal access token via environment variables.

 ```export FIGMA_PERSONAL_TOKEN=value```

 This token gives you access to the Figma API. Generate a personal Access Token through your user profile page or on [Figma API documentation website](https://www.figma.com/developers/api#access-tokens). If you use Fastlane just add the following line to `fastlane/.env` file

 ```FIGMA_PERSONAL_TOKEN=value```

### Manual
[Download](https://github.com/RedMadRobot/figma-export/releases) latest release and read [Usage](#usage)

### Homebrew
```
brew install RedMadRobot/formulae/figma-export
```

### CocoaPods + Fastlane
Add the following line to your Podfile:
```ruby
pod 'FigmaExport'
```

This will download the FigmaExport binaries and dependencies in `Pods/` during your next
`pod install` execution and will allow you to invoke it via `Pods/FigmaExport/Release/figma-export` in your Fastfile.

Add the following line to your Fastfile:
```ruby
lane :sync_colors do
  Dir.chdir("../") do
    sh "Pods/FigmaExport/Release/figma-export colors ."
  end
end
```

Don't forget to place figma-export.yaml file at the root of the project directory.

Run `fastlane sync_colors` to run FigmaExport.

## Usage
1. Open `Terminal.app`
2. Go (cd) to folder with `figma-export` file
3. Run `figma-export`
  
   To export colors use `colors` argument:

   `./figma-export colors -i figma-export.yaml`

   To export icon use `icons` argument:

   `./figma-export icons -i figma-export.yaml`
   
   To export images use `images` argument:

   `./figma-export images -i figma-export.yaml`

   To export typography use `typography` argument:

   `./figma-export typography -i figma-export.yaml`

### Arguments

**Export specific icons/images**

If you want to export specific icons/images you can list their names in the last argument like this:

`./figma-export icons "ic/24/edit"` — Exports only one icon.

`./figma-export icons "ic/24/edit, ic/16/notification"` — Exports two icons

`./figma-export icons "ic/24/videoplayer/*"` — Exports all icons which names starts with `ic/24/videoplayer/`

`./figma-export icons` — Exports all the icons.

**Configuration file**

Argument `-i` or `-input` specifies path to `figma-export.yaml` file where all the properties stores: figma, ios, android.

If `figma-export.yaml` file is next to the `figma-export` executable file you can omit `-i` option.

 `./figma-export colors`

Example of `figma-export.yaml` file:
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
  mainRes: "./main/res"

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

### Exporting Typography

1. Add a custom font to the Xcode project. Drag & drop font file to the Xcode project, set target membership, and add font file name in the Info.plist file. [See developer documentation for more info.](https://developer.apple.com/documentation/uikit/text_display_and_fonts/adding_a_custom_font_to_your_app)<br><img src="images/fonts.png" width="400" />
2. Run `figma-export typography` to export text styles
3. Add generated Swift files to your Xcode project. FigmaExport doesn’t add swift files to `.xcodeproj` file.
4. Use generated fonts and labels in your code. E.g. `button.titleLabel?.font = UIFont.body()`, `let label = HeaderLabel()`.

## Design requirements

If a color, icon or image is unique for iOS or Android platform, it should contains "ios" or "android" word in the description field in the properties. If a color, icon or image is used only by the designer and it should not be exported, the word "none" should be specified in the description field.

**Styles and Components must be published to a Team Library.**

For `figma-export colors`

If you support dark mode your figma project must contains two files. One should contains a dark color palette, and the another light color palette. Names and number of the colors must matches.

Example

File | Styles
------------ | -------------
<img src="images/dark.png" width="352" /> | <img src="images/dark_c.png" width="200" />
<img src="images/light.png" width="352" /> | <img src="images/light_c.png" width="200" />

For `figma-export icons`

Your Figma file must contains a frame with `Icons` name which contains components for each icon.

For `figma-export images`

Your Figma file must contains a frame with `Illustrations` name which contains components for each illustration.
If you support dark mode you must have two Figma files.

For `figma-export typography`.

Your Figma file must contains Text Styles.

#### Dynamic Type
It is recommended to support [Dynamic Type](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/#dynamic-type-sizes). Dynamic Type provides additional flexibility by letting readers choose their preferred text size.

If you want to support Dynamic Type you should specify iOS native text style for your custom text styles in the description field of Text Style. Available iOS native text styles you can find on Human Interface Guidlines page in [Typography/Dynamic Type Sizes](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/typography/#dynamic-type-sizes).

For example: You have `header` text style with 20 pt font size. Native iOS text style that matches is "Title 3". In the description field of your `header` text style you should specify "Title 3".

Advice: Font in Tab Bar and standard Navigation Bar must not support Dynamic Type.

## Example iOS project

There are 2 example iOS projects in `Example` and `ExampleSwiftUI` directories which demostrates how to use figma-export with UIKit and SwiftUI.

<img src="images/figma.png" width="800" />

The UI-Kit of this project in Figma:

[FigmaExport Example File [Light]](https://www.figma.com/file/BEjfU0kCVnPqXdRLfoLvkf/FigmaExport-Example-File-Dark)

<a href="https://www.figma.com/file/BEjfU0kCVnPqXdRLfoLvkf/FigmaExport-Example-File-Dark"><img src="images/figma_l.png" width="600" /></a>

[FigmaExport Example File [Dark]](https://www.figma.com/file/QwF30YrucxVwQyBNT0C09i/FigmaExport-Example-File-Dark)

<a href="https://www.figma.com/file/QwF30YrucxVwQyBNT0C09i/FigmaExport-Example-File-Dark"><img src="images/figma_d.png" width="600" /></a>

**How to setup iOS project**
1. Open `Example/fastlane/.env` file.
2. Change FIGMA_PERSONAL_TOKEN to your personal Figma token.
3. Go to `Example` folder.
4. Run the following command in Termanal to install cocoapods and fastlane: `bundle install`
5. Run the following command in Termanal to install figma-export: `bundle exec pod install`

**How to export resources from figma**
* To export colors run: `bundle exec fastlane export_colors`
* To export icons run: `bundle exec fastlane export_icons`
* To export images run: `bundle exec fastlane export_images`
* To export typography run: `bundle exec fastlane export_typography`

## Contributing

We'd love to accept your pull requests to this project.

## License

figma-export is released under the MIT license. [See LICENSE](./LICENSE) for details.

## Feedback

If you have any issues with the FigmaExport or you want some new features feel free to create an issue or contact me.

## Authors

Daniil Subbotin - d.subbotin@redmadrobot.com
