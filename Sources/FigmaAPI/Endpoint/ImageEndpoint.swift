import Foundation
#if os(Linux)
import FoundationNetworking
#endif

public class FormatParams: Encodable {
    /// A number between 0.01 and 4, the image scaling factor
    public let scale: Double?
    /// A string enum for the image output format, can be jpg, png, svg, or pdf
    public let format: String
    
    /// Use the full dimensions of the node regardless of whether or not it is cropped or the space around it is empty. Use this to export text nodes without cropping. Default: true.
    public var useAbsoluteBounds = true
    
    public init(scale: Double? = nil, format: String) {
        self.scale = scale
        self.format = format
    }
    
    var queryItems: [URLQueryItem] {
        var items = [
            URLQueryItem(name: "format", value: format),
            URLQueryItem(name: "use_absolute_bounds", value: String(useAbsoluteBounds)),
        ]
        if let scale {
            items.append(URLQueryItem(name: "scale", value: String(scale)))
        }
        return items
    }
}

public class SVGParams: FormatParams {
    /// Whether to include id attributes for all SVG elements. Default: false.
    public var svgIncludeId = false

    /// Whether to simplify inside/outside strokes and use stroke attribute if possible instead of <mask>. Default: true.
    public var svgSimplifyStroke = false

    public init() {
        super.init(format: "svg")
    }

    override var queryItems: [URLQueryItem] {
        var items = super.queryItems
        items.append(URLQueryItem(name: "svg_include_id", value: String(svgIncludeId)))
        items.append(URLQueryItem(name: "svg_simplify_stroke", value: String(svgSimplifyStroke)))
        return items
    }
}

public class PDFParams: FormatParams {
    public init() {
        super.init(format: "pdf")
    }
}

public class PNGParams: FormatParams {
    public init(scale: Double) {
        super.init(scale: scale, format: "png")
    }
}

public struct ImageEndpoint: BaseEndpoint {
    
    public typealias Content = [NodeId: ImagePath?]

    private let nodeIds: String
    private let fileId: String
    private let params: FormatParams
    
    public init(fileId: String, nodeIds: [String], params: FormatParams) {
        self.fileId = fileId
        self.nodeIds = nodeIds.joined(separator: ",")
        self.params = params
    }

    func content(from root: ImageResponse) -> [NodeId: ImagePath?] {
        return root.images
    }

    public func makeRequest(baseURL: URL) -> URLRequest {
        let url = baseURL
            .appendingPathComponent("images")
            .appendingPathComponent(fileId)
        
        var comps = URLComponents(url: url, resolvingAgainstBaseURL: false)
        comps?.queryItems = params.queryItems
        comps?.queryItems?.append(URLQueryItem(name: "ids", value: nodeIds))
        return URLRequest(url: comps!.url!)
    }

}

public struct ImageResponse: Decodable {
    public let images: [NodeId: ImagePath?]
}

public typealias ImagePath = String
