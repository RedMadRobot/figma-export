import Foundation

enum AssetsValidatorError: LocalizedError {
    case badName(name: String)
    case countMismatch(light: Int, dark: Int)
    case countMismatchLightHighContrastColors(light: Int, lightHC: Int)
    case countMismatchDarkHighContrastColors(dark: Int, darkHC: Int)
    case foundDuplicate(assetName: String)
    case secondAssetsNotFoundInFirstPalette(assets: [String], firstAssetsName: String, secondAssetsName: String)
    case descriptionMismatch(assetName: String, light: String, dark: String)

    var errorDescription: String? {
        var error: String
        switch self {
        case .badName(let name):
            error = "Bad asset name «\(name)»"
        case .countMismatch(let light, let dark):
            error = "The number of assets doesn’t match. Light theme contains \(light), and dark \(dark)."
        case .countMismatchLightHighContrastColors(let light, let lightHC):
            error = "The number of assets doesn’t match. Light color palette contains \(light), and light high contrast color palette \(lightHC)."
        case .countMismatchDarkHighContrastColors(let dark, let darkHC):
            error = "The number of assets doesn’t match. Dark color palette contains \(dark), and dark high contrast color palette \(darkHC)."
        case .secondAssetsNotFoundInFirstPalette(let secondAsset, let firstAssetsName, let secondAssetsName):
            error = "\(firstAssetsName) theme doesn’t contains following assets: \(secondAsset.joined(separator: ", ")), which exists in \(secondAssetsName.lowercased()) theme. Add these assets to \(firstAssetsName.lowercased()) theme and publish to the Team Library."
        case .foundDuplicate(let assetName):
            error = "Found duplicates of asset with name \(assetName). Remove duplicates."
        case .descriptionMismatch(let assetName, let light, let dark):
            error = "Asset with name \(assetName) have different description. In dark theme «\(dark)», in light theme «\(light)»"
        }
        return "❌ \(error)"
    }
}
