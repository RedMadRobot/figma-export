import Foundation
import FigmaAPI
import FigmaExportCore

final class ImagesLoader {

    let figmaClient: FigmaClient
    let params: Params
    let platform: Platform
    
    private var iconsFrameName: String {
        params.common?.icons?.figmaFrameName ?? "Icons"
    }
    
    private var imagesFrameName: String {
        params.common?.images?.figmaFrameName ?? "Illustrations"
    }
    
    init(figmaClient: FigmaClient, params: Params, platform: Platform) {
        self.figmaClient = figmaClient
        self.params = params
        self.platform = platform
    }

    func loadIcons(filter: String? = nil) throws -> [ImagePack] {
        switch (platform, params.ios?.icons.format) {
        case (.android, _),
             (.ios, .svg):
            return try _loadImages(
                fileId: params.figma.lightFileId,
                frameName: iconsFrameName,
                params: SVGParams(),
                filter: filter
            )
        case (.ios, _):
            return try _loadImages(
                fileId: params.figma.lightFileId,
                frameName: iconsFrameName,
                params: PDFParams(),
                filter: filter
            )
        }
    }

    func loadImages(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        switch (platform, params.android?.images?.format) {
        case (.android, .png), (.android, .webp), (.ios, .none):
            let lightImages = try loadPNGImages(
                fileId: params.figma.lightFileId,
                frameName: imagesFrameName,
                filter: filter,
                platform: platform)
            let darkImages = try params.figma.darkFileId.map {
                try loadPNGImages(
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
            
            let darkPacks = try params.figma.darkFileId.map {
                try _loadImages(
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
                $0.containingFrame.name == frameName &&
                    ($0.description == platform.rawValue || $0.description == nil || $0.description == "") &&
                    $0.description?.contains("none") == false
            }
        
        if let filter = filter {
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
        let imagesDict = try fetchImageComponents(fileId: fileId, frameName: frameName, filter: filter)
        
        guard !imagesDict.isEmpty else {
            throw FigmaExportError.componentsNotFound
        }
        
        let imagesIds: [NodeId] = imagesDict.keys.map { $0 }
        let imageIdToImagePath = try loadImages(fileId: fileId, nodeIds: imagesIds, params: params)

        // Group images by name
        let groups = Dictionary(grouping: imagesDict) { $1.name.parseNameAndIdiom(platform: platform).name }

        // Create image packs for groups
        let imagePacks = groups.compactMap { packName, components -> ImagePack? in
            let packImages = components.compactMap { nodeId, component -> Image? in
                guard let urlString = imageIdToImagePath[nodeId], let url = URL(string: urlString) else {
                    return nil
                }
                let (name, idiom) = component.name.parseNameAndIdiom(platform: platform)
                return Image(name: name, scale: .all, idiom: idiom, url: url, format: params.format)
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

        let imagesIds: [NodeId] = imagesDict.keys.map { $0 }
        let scales = platform == .android ? [1, 2, 3, 1.5, 4.0] : [1, 2, 3]

        var images: [Double: [NodeId: ImagePath]] = [:]
        for scale in scales {
            images[scale] = try loadImages(fileId: fileId, nodeIds: imagesIds, params: PNGParams(scale: scale))
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

    // MARK: - Figma

    private func loadComponents(fileId: String) throws -> [Component] {
        let endpoint = ComponentsEndpoint(fileId: fileId)
        return try figmaClient.request(endpoint)
    }

    private func loadImages(fileId: String, nodeIds: [NodeId], params: FormatParams) throws -> [NodeId: ImagePath] {
        let endpoint = ImageEndpoint(fileId: fileId, nodeIds: nodeIds, params: params)
        return try figmaClient.request(endpoint)
    }
}

// MARK: - String Utils

private extension String {

    func parseNameAndIdiom(platform: Platform) -> (name: String, idiom: String) {
        switch platform {
        case .android:
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
