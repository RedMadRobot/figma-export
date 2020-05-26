Pod::Spec.new do |spec|
    spec.name           = "FigmaExport"
    spec.version        = "0.8.2"
    spec.summary        = "Command line utility to export colors, icons and images from Figma to Xcode / Android Studio project."
    spec.homepage       = "https://github.com/RedMadRobot/figma-export"  
    spec.license        = { type: "MIT", file: "LICENSE" }
    spec.author         = { "Daniil Subbotin" => "mail@subdan.ru" }
    spec.source         = { git: 'https://github.com/RedMadRobot/figma-export.git', tag: spec.version.to_s }
    spec.preserve_paths = 'Release/figma-export'
end
