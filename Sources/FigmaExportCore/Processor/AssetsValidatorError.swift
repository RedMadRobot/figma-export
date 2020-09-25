import Foundation

enum AssetsValidatorError: LocalizedError {
    case badName(name: String)
    case countMismatch(light: Int, dark: Int)
    case foundDuplicate(assetName: String)
    case lightAssetsNotFoundInDarkPalette(assets: [String])
    case darkAssetsNotFoundInLightPalette(assets: [String])
    case descriptionMismatch(assetName: String, light: String, dark: String)

    var errorDescription: String? {
        switch self {
        case .badName(let name):
            return "Bad asset name «\(name)»"
        case .countMismatch(let light, let dark):
            return "The number of assets doesn’t match. Light theme contains \(light), and dark \(dark)."
        case .lightAssetsNotFoundInDarkPalette(let lights):
            return "Dark theme doesn’t contains following assets: \(lights.joined(separator: ", ")), which exists in light theme. Add these assets to dark theme and publish to the Team Library."
        case .darkAssetsNotFoundInLightPalette(let darks):
            return "Light theme doesn’t contains following assets: \(darks.joined(separator: ", ")), which exists in dark theme. Add these assets to light theme and publish to the Team Library."
        case .foundDuplicate(let assetName):
            return "Found duplicates of asset with name \(assetName). Remove duplicates."
        case .descriptionMismatch(let assetName, let light, let dark):
            return "Asset with name \(assetName) have different description. In dark theme «\(dark)», in light theme «\(light)»"
        }
    }
}
