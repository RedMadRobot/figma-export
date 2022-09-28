import Foundation
import FigmaAPI
import FigmaExportCore

/// Loads spacings from Figma
final class SpacingsLoader {

    private let client: Client
    private let params: Params
    private let platform: Platform

    private var spacingsFrameName: String {
        params.common?.spacings?.figmaFrameName ?? "Spacing"
    }

    private var spacingsVerticalFrameName: String {
        params.common?.spacings?.figmaVerticalStateName ?? "Vertical"
    }

    private var spacingsHorizontalFrameName: String {
        params.common?.spacings?.figmaHorizontalStateName ?? "Horizontal"
    }

    init(client: Client, params: Params, platform: Platform) {
        self.client = client
        self.params = params
        self.platform = platform
    }

    func load() throws -> [Spacing] {
        return try loadSpacings(fileId: params.figma.lightFileId)
    }

    private func loadSpacings(fileId: String) throws -> [Spacing] {
        let formatter = NumberFormatter()

        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1

        return try fetchSpacingsComponents(fileId: fileId).compactMap { component in
            guard let size = extractSizeFrom(componentName: component.name),
                  let formattedSize = formatter.string(from: NSNumber(value: size)),
                  let containingStateGroup = component.containingFrame.containingStateGroup?.name,
                  let prefix = calculatePrefixFrom(stateGroup: containingStateGroup) else { return nil }

            return Spacing(name: "\(prefix)_\(formattedSize)", size: size)
        }
    }
    
    // MARK: - Helpers

    private func fetchSpacingsComponents(fileId: String) throws -> [Component] {
        return try loadComponents(fileId: fileId)
                .filter {
                    $0.containingFrame.name == spacingsFrameName && $0.useForPlatform(platform)
                }
    }
    
    // MARK: - Figma
    private func loadComponents(fileId: String) throws -> [Component] {
        let endpoint = ComponentsEndpoint(fileId: fileId)
        return try client.request(endpoint)
    }

    private func calculatePrefixFrom(stateGroup: String) -> String? {
        switch (stateGroup) {
        case spacingsVerticalFrameName: return "v"
        case spacingsHorizontalFrameName: return "h"
        default: return nil
        }
    }

    private func extractSizeFrom(componentName: String) -> Double? {
        let regex = try? NSRegularExpression(pattern: #"[Ss]ize=(?<size>\d+)"#)
        let matches = regex?.matches(
                in: componentName,
                options: [],
                range: NSRange(componentName.startIndex..<componentName.endIndex, in: componentName)
        )

        guard let match = matches?.first,
              let matchRange = Range(match.range(withName: "size"), in: componentName) else { return nil }

        return Double(String(componentName[matchRange]))
    }
}
