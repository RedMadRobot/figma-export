import Foundation

public enum AssetsValidatorWarning: LocalizedError {
    case lightAssetsNotFoundInDarkPalette(assets: [String])

    public var errorDescription: String? {
        var warning: String
        switch self {
        case .lightAssetsNotFoundInDarkPalette(let lights):
            warning = "The following assets will be considered universal because they are not found in the dark palette: \(lights.joined(separator: ", "))"
        }
        return "⚠️ \(warning)"
    }
}
