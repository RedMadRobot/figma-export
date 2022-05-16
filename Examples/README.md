## Example projects

The UI-Kit of the example project in Figma:

[FigmaExport Example File [Light]](https://www.figma.com/file/yk9zOE5Rf8X6KWBfXQXrhS/FigmaExport-Example-File-%5BLight%5D)

<a href="https://www.figma.com/file/yk9zOE5Rf8X6KWBfXQXrhS/FigmaExport-Example-File-%5BLight%5D"><img src="../images/figma_l.png" width="600" /></a>

[FigmaExport Example File [Dark]](https://www.figma.com/file/x2oLS8TNqGSrugXMqe3XpV/FigmaExport-Example-File-%5BDark%5D)

<a href="https://www.figma.com/file/x2oLS8TNqGSrugXMqe3XpV/FigmaExport-Example-File-%5BDark%5D"><img src="../images/figma_d.png" width="600" /></a>

Note that these files use free Figma plan therefore exporting icons and images doesn't work. To be able to export image components Figma File must be located in the Team that have Professional or Organisation Figma plan.

### Example iOS project

There are 2 example iOS projects in `Example` and `ExampleSwiftUI` directories which demostrates how to use figma-export with UIKit and SwiftUI.

<img src="../images/figma.png" />

**How to setup iOS project**
1. Open `Example/fastlane/.env` file.
2. Change FIGMA_PERSONAL_TOKEN to your personal Figma token.
3. Go to `Example` folder.
4. Run the following command in Termanal to install cocoapods and fastlane: `bundle install`
5. Run the following command in Termanal to install figma-export: `bundle exec pod install`

**How to export resources from figma**
* To export colors run: `bundle exec fastlane export_colors`
* To export typography run: `bundle exec fastlane export_typography`

### Example Android project

There is an example Android Studio project in `AndroidExample` directory which demostrates how to use `figma-export`.

<img src="../images/android_example.png"/>

**How to export resources from figma to the project**
* To export colors run: `figma-export colors`
* To export typography run: `figma-export typography`

### Example Android Jetpack Compose project

There is an example Android Studio project in `AndroidComposeExample` directory which demostrates how to use `figma-export` configured for Jetpack Compose.

You can find the generated code for compose in the package `com.redmadrobot.androidcomposeexample.ui.figmaexport`

**How to export resources from figma to the project**
* To export colors run: `figma-export colors`
* To export typography run: `figma-export typography`
