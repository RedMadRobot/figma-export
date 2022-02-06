// swift-tools-version:5.4
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
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "4.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.0"),
        // Revert when PR https://github.com/stencilproject/Stencil/pull/287 will be merged
        .package(url: "https://github.com/subdan/Stencil.git", from: "0.14.5"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "8.5.0"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.3.0"),
    ],
    targets: [
        
        // Main target
        .executableTarget(
            name: "FigmaExport",
            dependencies: [
                "FigmaAPI",
                "FigmaExportCore",
                "XcodeExport",
                "AndroidExport",
                .product(name: "XcodeProj", package: "XcodeProj"),
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
            dependencies: ["FigmaExportCore", .product(name: "Stencil", package: "Stencil")],
			resources: [
              	.copy("Resources/")
	        ]
        ),

        // Exports resources to Android project
        .target(
            name: "AndroidExport",
            dependencies: ["FigmaExportCore", "Stencil"],
            resources: [
                .copy("Resources/")
            ]
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
            dependencies: ["XcodeExport", .product(name: "CustomDump", package: "swift-custom-dump")]
        ),
        .testTarget(
            name: "AndroidExportTests",
            dependencies: ["AndroidExport", .product(name: "CustomDump", package: "swift-custom-dump")]
        )
    ]
)
