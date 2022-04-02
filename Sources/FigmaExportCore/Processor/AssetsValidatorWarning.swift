import Foundation

public enum AssetsValidatorWarning: LocalizedError {
    case lightAssetsNotFoundInDarkPalette(assets: [String])
    case lightHCAssetsNotFoundInLightPalette(assets: [String])
    case darkHCAssetsNotFoundInDarkPalette(assets: [String])
    
    public var errorDescription: String? {
        var warning: String
        switch self {
        case .lightAssetsNotFoundInDarkPalette(let lights):
            warning = "The following assets will be considered universal because they are not found in the dark palette: \(lights.joined(separator: ", "))"
        case .lightHCAssetsNotFoundInLightPalette(let lightsHC):
            warning = "The following assets will be considered universal because they are not found in the light palette: \(lightsHC.joined(separator: ", "))"
        case .darkHCAssetsNotFoundInDarkPalette(let darkHC):
            warning = "The following assets will be considered universal because they are not found in the dark palette: \(darkHC.joined(separator: ", "))"
        }
        return "⚠️ \(warning)"
    }
}
