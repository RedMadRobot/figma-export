let androidConfigFileContents = #"""
---
figma:
  # Identifier of the file containing light color palette, icons and light images. To obtain a file id, open the file in the browser. The file id will be present in the URL after the word file and before the file name.
  lightFileId: shPilWnVdJfo10YF12345
  # [optional] Identifier of the file containing dark color palette and dark images.
  darkFileId: KfF6DnJTWHGZzC912345

# [optional] Android export parameters
android:
  # Relative or absolute path to the `main/res` folder including it. The colors/icons/imags will be exported to this folder
  mainRes: "./main/res"
  # Parameters for exporting icons
  icons:
    # Where to place icons relative to `mainRes`? FigmaExport clears this directory every time your execute `figma-export icons` command
    output: "figma-export-icons"
  # Parameters for exporting images
  images:
    # Where to place images relative to `mainRes`? FigmaExport clears this directory every time your execute `figma-export images` command
    output: "figma-export-images"
    # Image file format: svg or png
    format: webp
    # Format options for webp format only
    webpOptions:
      # Encoding type: lossy or lossless
      encoding: lossy
      # Encoding quality in percents. Only for lossy encoding.
      quality: 90

"""#
