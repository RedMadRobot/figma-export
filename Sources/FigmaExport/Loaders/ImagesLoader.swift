import Foundation
import FigmaAPI
import FigmaExportCore
import Logging

final class ImagesLoader {

    let client: Client
    let params: Params
    let platform: Platform

    private var iconsFrameName: String {
        params.common?.icons?.figmaFrameName ?? "Icons"
    }

    private var imagesFrameName: String {
        params.common?.images?.figmaFrameName ?? "Illustrations"
    }
    
    private let logger: Logger

    init(client: Client, params: Params, platform: Platform, logger: Logger) {
        self.client = client
        self.params = params
        self.platform = platform
        self.logger = logger
    }

    func loadIcons(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        if let useSingleFile = params.common?.icons?.useSingleFile, useSingleFile {
            return try loadIconsFromSingleFile(filter: filter)
        } else {
            return try loadIconsFromLightAndDarkFile(filter: filter)
        }
    }

    private func loadIconsFromSingleFile(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        let formatParams: FormatParams
        switch (platform, params.ios?.icons?.format) {
        case (.android, _),
             (.flutter, _),
             (.ios, .svg):
            formatParams = SVGParams()
        case (.ios, _):
            formatParams = PDFParams()
        }

        let icons = try _loadImages(
            fileId: params.figma.lightFileId,
            frameName: iconsFrameName,
            params: formatParams,
            filter: filter
        )
        let darkSuffix = params.common?.icons?.darkModeSuffix ?? "_dark"
        let lightIcons = icons
            .filter { !$0.name.hasSuffix(darkSuffix)}
            .map { updateRenderMode($0) }
        let darkIcons = icons
            .filter { $0.name.hasSuffix(darkSuffix) }
            .map { icon -> ImagePack in
                var newIcon = icon
                newIcon.name = String(icon.name.dropLast(darkSuffix.count))
                return newIcon
            }
            .map { updateRenderMode($0) }
        return (lightIcons, darkIcons)
    }

    private func updateRenderMode(_ icon: ImagePack) -> ImagePack {
        // Filtering at suffixes
        var renderMode = params.ios?.icons?.renderMode ?? .template
        let defaultSuffix = renderMode == .template ? params.ios?.icons?.renderModeDefaultSuffix : nil
        let originalSuffix = renderMode == .template ? params.ios?.icons?.renderModeOriginalSuffix : nil
        let templateSuffix = renderMode != .template ? params.ios?.icons?.renderModeTemplateSuffix : nil
        var suffix: String?

        if let defaultSuffix, icon.name.hasSuffix(defaultSuffix) {
            renderMode = .default
            suffix = defaultSuffix
        } else if let originalSuffix, icon.name.hasSuffix(originalSuffix) {
            renderMode = .original
            suffix = originalSuffix
        } else if let templateSuffix, icon.name.hasSuffix(templateSuffix) {
            renderMode = .template
            suffix = templateSuffix
        }
        var newIcon = icon
        newIcon.name = String(icon.name.dropLast(suffix?.count ?? 0))
        newIcon.renderMode = renderMode
        return newIcon
    }

    private func loadIconsFromLightAndDarkFile(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        let formatParams: FormatParams
        switch (platform, params.ios?.icons?.format) {
        case (.android, _),
             (.flutter, _),
             (.ios, .svg):
            formatParams = SVGParams()
        case (.ios, _):
            formatParams = PDFParams()
        }

        let lightIcons = try _loadImages(
            fileId: params.figma.lightFileId,
            frameName: iconsFrameName,
            params: formatParams,
            filter: filter
        ).map { updateRenderMode($0) }
        let darkIcons = params.figma.darkFileId.flatMap {
            try? _loadImages(
                fileId: $0,
                frameName: iconsFrameName,
                params: formatParams,
                filter: filter
            ).map { updateRenderMode($0) }
        }
        return (lightIcons, darkIcons)
    }

    func loadImages(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        if let useSingleFile = params.common?.images?.useSingleFile, useSingleFile {
            return try loadImagesFromSingleFile(filter: filter)
        } else {
            return try loadImagesFromLightAndDarkFile(filter: filter)
        }
    }

    private func loadImagesFromSingleFile(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        let darkSuffix = params.common?.images?.darkModeSuffix ?? "_dark"

        let androidFormat = params.android?.images?.format
        let flutterFormat = params.flutter?.images?.format
        let isSVG = (platform == .android && androidFormat == .svg)
        || (platform == .flutter && flutterFormat == .svg)

        if !isSVG {
            let images = try loadPNGImages(
                fileId: params.figma.lightFileId,
                frameName: imagesFrameName,
                filter: filter,
                platform: platform)
            let lightImages = images
                .filter { !$0.name.hasSuffix(darkSuffix) }
            let darkImages = images
                .filter { $0.name.hasSuffix(darkSuffix) }
                .map { image -> ImagePack in
                    var newImage = image
                    newImage.name = String(image.name.dropLast(darkSuffix.count))
                    return newImage
                }
            return (lightImages, darkImages)
        } else {
            let pack = try _loadImages(
                fileId: params.figma.lightFileId,
                frameName: imagesFrameName,
                params: SVGParams(),
                filter: filter)
            let lightPack = pack
                .filter { !$0.name.hasSuffix(darkSuffix) }
            let darkPack = pack
                .filter { $0.name.hasSuffix(darkSuffix) }
                .map { image -> ImagePack in
                    var newImage = image
                    newImage.name = String(image.name.dropLast(darkSuffix.count))
                    return newImage
                }
            return (lightPack, darkPack)
        }
    }

    private func loadImagesFromLightAndDarkFile(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        switch (platform, params.android?.images?.format) {
        case (.android, .png), (.android, .webp), (.ios, _):
            let lightImages = try loadPNGImages(
                fileId: params.figma.lightFileId,
                frameName: imagesFrameName,
                filter: filter,
                platform: platform)
            let darkImages = params.figma.darkFileId.flatMap {
                try? loadPNGImages(
                    fileId: $0,
                    frameName: imagesFrameName,
                    filter: filter,
                    platform: platform)
            }
            return (
                lightImages,
                darkImages
            )
        default:
            let lightPacks = try _loadImages(
                fileId: params.figma.lightFileId,
                frameName: imagesFrameName,
                params: SVGParams(),
                filter: filter)

            let darkPacks = params.figma.darkFileId.flatMap {
                try? _loadImages(
                    fileId: $0,
                    frameName: imagesFrameName,
                    params: SVGParams(),
                    filter: filter)
            }
            return (lightPacks, darkPacks)
        }
    }

    // MARK: - Helpers

    private func fetchImageComponents(fileId: String, frameName: String, filter: String? = nil) throws -> [NodeId: Component] {
        var components = try loadComponents(fileId: fileId)
            .filter {
                $0.containingFrame.name == frameName && $0.useForPlatform(platform)
            }

        if let filter {
            let assetsFilter = AssetsFilter(filter: filter)
            components = components.filter { component -> Bool in
                assetsFilter.match(name: component.name)
            }
        }

        return Dictionary(uniqueKeysWithValues: components.map { ($0.nodeId, $0) })
    }

    private func _loadImages(
        fileId: String,
        frameName: String,
        params: FormatParams,
        filter: String? = nil
    ) throws -> [ImagePack] {
        var imagesDict = try fetchImageComponents(fileId: fileId, frameName: frameName, filter: filter)

        guard !imagesDict.isEmpty else {
            throw FigmaExportError.componentsNotFound
        }
        
        // Component name must not be empty
        imagesDict = imagesDict.filter { (key: NodeId, component: Component) in
            if component.name.trimmingCharacters(in: .whitespaces).isEmpty {
                logger.warning("""
                Found a component with empty name.
                Page name: \(component.containingFrame.pageName)
                Frame: \(component.containingFrame.name ?? "nil")
                Description: \(component.description ?? "nil")
                The component wont be exported. Fix component name in the Figma file and try again.
                """)
                return false
            }
            return true
        }
        
        logger.info("Fetching vector images...")
        let imageIdToImagePath = try loadImages(fileId: fileId, imagesDict: imagesDict, params: params)
        
        // Remove components for which image file could not be fetched
        let badNodeIds = Set(imagesDict.keys).symmetricDifference(Set(imageIdToImagePath.keys))
        badNodeIds.forEach { nodeId in
            imagesDict.removeValue(forKey: nodeId)
        }

        // Group images by name
        let groups = Dictionary(grouping: imagesDict) { $1.name.parseNameAndIdiom(platform: platform).name }

        // Create image packs for groups
        let imagePacks = groups.compactMap { packName, components -> ImagePack? in
            let packImages = components.compactMap { nodeId, component -> Image? in
                guard let urlString = imageIdToImagePath[nodeId], let url = URL(string: urlString) else {
                    return nil
                }
                let (name, idiom) = component.name.parseNameAndIdiom(platform: platform)
                let isRTL = component.useRTL()
                return Image(name: name, scale: .all, idiom: idiom, url: url, format: params.format, isRTL: isRTL)
            }
            return ImagePack(name: packName, images: packImages, platform: platform)
        }
        return imagePacks
    }

    private func loadPNGImages(fileId: String, frameName: String, filter: String? = nil, platform: Platform) throws -> [ImagePack] {
        let imagesDict = try fetchImageComponents(fileId: fileId, frameName: frameName, filter: filter)

        guard !imagesDict.isEmpty else {
            throw FigmaExportError.componentsNotFound
        }

        let scales = getScales(platform: platform)

        var images: [Double: [NodeId: ImagePath]] = [:]
        for scale in scales {
            logger.info("Fetching PNG images for scale \(scale)...")
            images[scale] = try loadImages(fileId: fileId, imagesDict: imagesDict, params: PNGParams(scale: scale))
        }

        // Group images by name
        let groups = Dictionary(grouping: imagesDict) { $1.name.parseNameAndIdiom(platform: platform).name }

        // Create image packs for groups
        let imagePacks = groups.compactMap { packName, components -> ImagePack? in
            let packImages = components.flatMap { nodeId, component -> [Image] in
                let (name, idiom) = component.name.parseNameAndIdiom(platform: platform)
                return scales.compactMap { scale -> Image? in
                    guard let urlString = images[scale]?[nodeId], let url = URL(string: urlString) else {
                        return nil
                    }
                    return Image(name: name, scale: .individual(scale), idiom: idiom, url: url, format: "png")
                }
            }
            return ImagePack(name: packName, images: packImages, platform: platform)
        }
        return imagePacks
    }

    private func getScales(platform: Platform) -> [Double] {
        var validScales: [Double] = []
        var customScales: [Double] = []
        let filterScales = { (platformScales: [Double]?) -> [Double] in
            platformScales?.filter { validScales.contains($0) } ?? []
        }
        if platform == .android {
            validScales = [1, 2, 3, 1.5, 4.0]
            customScales = filterScales(params.android?.images?.scales)
        } else {
            validScales = [1, 2, 3]
            customScales = filterScales(params.ios?.images?.scales)
        }
        return customScales.isEmpty ? validScales : customScales
    }

    // MARK: - Figma

    private func loadComponents(fileId: String) throws -> [Component] {
        let endpoint = ComponentsEndpoint(fileId: fileId)
        return try client.request(endpoint)
    }

    private func loadImages(fileId: String, imagesDict: [NodeId: Component], params: FormatParams) throws -> [NodeId: ImagePath] {
        let batchSize = 100
        
        let nodeIds: [NodeId] = imagesDict.keys.map { $0 }
        
        let keysWithValues: [(NodeId, ImagePath)] = try nodeIds.chunked(into: batchSize)
            .map { ImageEndpoint(fileId: fileId, nodeIds: $0, params: params) }
            .map { try client.request($0) }
            .flatMap { dict in
                dict.compactMap { nodeId, imagePath in
                    if let imagePath {
                        return (nodeId, imagePath)
                    } else {
                        let componentName = imagesDict[nodeId]?.name ?? ""
                        logger.error("Unable to get image for node with id = \(nodeId). Please check that component \(componentName) in the Figma file is not empty. Skipping this file...")
                        return nil
                    }
                }
            }
        return Dictionary(uniqueKeysWithValues: keysWithValues)
    }
}

// MARK: - String Utils

private extension String {

    func parseNameAndIdiom(platform: Platform) -> (name: String, idiom: String) {
        switch platform {
        case .android, .flutter:
            return (self, "")
        case .ios:
            guard let regex = try? NSRegularExpression(pattern: "(.*)~(.*)$") else {
                return (self, "")
            }
            guard let match = regex.firstMatch(in: self, range: NSRange(startIndex..., in: self)),
                  let name = Range(match.range(at: 1), in: self),
                  let idiom = Range(match.range(at: 2), in: self) else {
                return (self, "")
            }
            return (String(self[name]), String(self[idiom]))
        }
    }

}

extension Component {
    
    public func useForPlatform(_ platform: Platform) -> Bool {
        guard let description = description, !description.isEmpty else {
            return true
        }
        
        let keywords = ["ios", "android", "none"]
        
        let hasNotKeywords = keywords.allSatisfy { !description.contains($0) }
        if hasNotKeywords {
            return true
        }
        
        if (description.contains("ios") && platform == .ios) ||
            (description.contains("android") && platform == .android) {
            return true
        }
        
        return false
    }
    
    public func useRTL() -> Bool {
        guard let description = description, !description.isEmpty else { return false }        
        return description.localizedCaseInsensitiveContains("rtl")
    }
}
