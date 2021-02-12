import Foundation

enum AssetsValidatorError: LocalizedError {
    case badName(name: String)
    case countMismatch(light: Int, dark: Int)
    case foundDuplicate(assetName: String)
    case darkAssetsNotFoundInLightPalette(assets: [String])
    case descriptionMismatch(assetName: String, light: String, dark: String)

    var errorDescription: String? {
        var error: String
        switch self {
        case .badName(let name):
            error = "Bad asset name «\(name)»"
        case .countMismatch(let light, let dark):
            error = "The number of assets doesn’t match. Light theme contains \(light), and dark \(dark)."
        case .darkAssetsNotFoundInLightPalette(let darks):
            error = "Light theme doesn’t contains following assets: \(darks.joined(separator: ", ")), which exists in dark theme. Add these assets to light theme and publish to the Team Library."
        case .foundDuplicate(let assetName):
            error = "Found duplicates of asset with name \(assetName). Remove duplicates."
        case .descriptionMismatch(let assetName, let light, let dark):
            error = "Asset with name \(assetName) have different description. In dark theme «\(dark)», in light theme «\(light)»"
        }
        return "❌ \(error)"
    }
}
