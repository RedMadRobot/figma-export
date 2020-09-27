// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "figma-export",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .executable(name: "figma-export", targets: ["FigmaExport"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "3.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/stencilproject/Stencil.git", from: "0.14.0"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "7.14.0")
    ],
    targets: [
        
        // Main target
        .target(
            name: "FigmaExport",
            dependencies: [
                "FigmaAPI",
                "FigmaExportCore",
                "XcodeExport",
                "AndroidExport",
                "XcodeProj",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
        
        // Shared target
        .target(name: "FigmaExportCore"),
        
        // Loads data via Figma REST API
        .target(name: "FigmaAPI"),
        
        // Exports resources to Xcode project
        .target(
            name: "XcodeExport",
            dependencies: ["FigmaExportCore", "Stencil"]
        ),

        // Exports resources to Android project
        .target(
            name: "AndroidExport",
            dependencies: ["FigmaExportCore"]
        ),
        
        // MARK: - Tests
        
        .testTarget(
            name: "FigmaExportTests",
            dependencies: ["FigmaExport"]
        ),
        .testTarget(
            name: "FigmaExportCoreTests",
            dependencies: ["FigmaExportCore"]
        ),
        .testTarget(
            name: "XcodeExportTests",
            dependencies: ["XcodeExport"]
        )
    ]
)
