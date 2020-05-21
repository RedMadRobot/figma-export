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
            return "Неправильное название «\(name)»"
        case .countMismatch(let light, let dark):
            return "Количество ассетов не совпадает. В светлой теме их \(light), а в темной теме \(dark)."
        case .lightAssetsNotFoundInDarkPalette(let lights):
            return "В темной теме не найдены ассеты: \(lights.joined(separator: ", ")), которые есть в светлой теме."
        case .darkAssetsNotFoundInLightPalette(let darks):
            return "В светлой теме не найдены ассеты: \(darks.joined(separator: ", ")), которые есть в темной теме."
        case .foundDuplicate(let assetName):
            return "Ассет \(assetName) встречается несколько раз."
        case .descriptionMismatch(let assetName, let light, let dark):
            return "Ассет \(assetName) имеет разный description. В тёмной теме «\(dark)», а в светлой «\(light)»"
        }
    }
}
