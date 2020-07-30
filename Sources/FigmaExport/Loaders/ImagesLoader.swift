import Foundation
import FigmaAPI
import FigmaExportCore

final class ImagesLoader {

    let figmaClient: FigmaClient
    let params: Params.Figma
    let platform: Platform
    
    init(figmaClient: FigmaClient, params: Params.Figma, platform: Platform) {
        self.figmaClient = figmaClient
        self.params = params
        self.platform = platform
    }

    func loadIcons(filter: String? = nil) throws -> [ImagePack] {
        if platform == .android {
            return try _loadImages(
                fileId: params.lightFileId,
                frameName: .icons,
                params: SVGParams(),
                filter: filter
            ).map { ImagePack.singleScale($0) }
        } else {
            return try _loadImages(
                fileId: params.lightFileId,
                frameName: .icons,
                params: PDFParams(),
                filter: filter
            ).map { ImagePack.singleScale($0) }
        }
    }

    func loadImages(filter: String? = nil) throws -> (light: [ImagePack], dark: [ImagePack]?) {
        if platform == .android {
            let light = try _loadImages(
                fileId: params.lightFileId,
                frameName: .illustrations,
                params: SVGParams(),
                filter: filter)
            
            let dark = try params.darkFileId.map {
                try _loadImages(
                    fileId: $0,
                    frameName: .illustrations,
                    params: SVGParams(),
                    filter: filter)
            }
            return (
                light.map { ImagePack.singleScale($0) },
                dark?.map { ImagePack.singleScale($0) }
            )
        } else {
            let lightImages = try _loadPNGImages(
                fileId: params.lightFileId,
                frameName: .illustrations,
                filter: filter)
            let darkImages = try params.darkFileId.map {
                try _loadPNGImages(
                    fileId: $0,
                    frameName: .illustrations,
                    filter: filter)
            }
            return (
                lightImages,
                darkImages
            )
        }
    }

    // MARK: - Helpers

    private func fetchImageComponents(fileId: String, frameName: FrameName, filter: String? = nil) throws -> [NodeId: Component] {
        var components = try loadComponents(fileId: fileId)
            .filter {
                $0.containingFrame.name == frameName.rawValue &&
                    ($0.description == platform.rawValue ||
                        $0.description == nil || $0.description == "")
            }
        
        if let filter = filter {
            let assetsFilter = AssetsFilter(filter: filter)
            components = components.filter { component -> Bool in
                assetsFilter.match(name: component.name)
            }
        }
        
        return Dictionary(uniqueKeysWithValues: components.map { ($0.nodeId, $0) })
    }

    private func _loadImages(fileId: String, frameName: FrameName, params: FormatParams, filter: String? = nil) throws -> [Image] {
        let imagesDict = try fetchImageComponents(fileId: fileId, frameName: frameName, filter: filter)
        let imagesIds: [NodeId] = imagesDict.keys.map { $0 }
        let imageIdToImagePath = try loadImages(fileId: fileId, nodeIds: imagesIds, params: params)
        
        return imageIdToImagePath.map { (imageId, imagePath) -> Image in
            let name = imagesDict[imageId]!.name
            return Image(
                name: name,
                url: URL(string: imagePath)!,
                format: params.format
            )
        }
    }

    private func _loadPNGImages(fileId: String, frameName: FrameName, filter: String? = nil) throws -> [ImagePack] {
        let imagesDict = try fetchImageComponents(fileId: fileId, frameName: frameName, filter: filter)
        let imagesIds: [NodeId] = imagesDict.keys.map { $0 }

        let imageIdToImagePath1 = try loadImages(fileId: fileId, nodeIds: imagesIds, params: PNGParams(scale: 1))
        let imageIdToImagePath2 = try loadImages(fileId: fileId, nodeIds: imagesIds, params: PNGParams(scale: 2))
        let imageIdToImagePath3 = try loadImages(fileId: fileId, nodeIds: imagesIds, params: PNGParams(scale: 3))

        return imagesIds.map { imageId -> ImagePack in

            let name = imagesDict[imageId]!.name

            let path1 = URL(string: imageIdToImagePath1[imageId]!)!
            let path2 = URL(string: imageIdToImagePath2[imageId]!)!
            let path3 = URL(string: imageIdToImagePath3[imageId]!)!

            let x1 = Image(name: name, url: path1, format: "png")
            let x2 = Image(name: name, url: path2, format: "png")
            let x3 = Image(name: name, url: path3, format: "png")

            return ImagePack.individualScales(x1: x1, x2: x2, x3: x3)
        }
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
