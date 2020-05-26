import Foundation
import FigmaExportCore

/// Process asset name
protocol AssetNameProcessable {
    
    var nameValidateRegexp: String? { get }
    var nameStyle: Params.NameStyle? { get }
    
    func isNameValid(_ name: String) -> Bool
    func normalizeName(_ name: String, style: Params.NameStyle) -> String
}

extension AssetNameProcessable {
    
    func isNameValid(_ name: String) -> Bool {
        if let regexp = nameValidateRegexp {
            return name.range(of: regexp, options: .regularExpression) != nil
        } else {
            return true
        }
    }
    
    func normalizeName(_ name: String, style: Params.NameStyle) -> String {
        switch style {
        case .camelCase:
            return name.lowerCamelCased()
        case .snakeCase:
            return name.snakeCased()
        }
    }
}

protocol AssetsProcessable: AssetNameProcessable {
    associatedtype AssetType: Asset
    typealias ProcessingPairResult = Result<[AssetPair<AssetType>], ErrorGroup>
    typealias ProcessingResult = Result<[AssetType], ErrorGroup>
    
    var platform: Platform { get }
    
    func process(light: [AssetType], dark: [AssetType]?) -> ProcessingPairResult
    func process(assets: [AssetType]) -> ProcessingResult
}

struct ColorsProcessor: AssetsProcessable {
    typealias AssetType = Color
    
    let platform: Platform
    let nameValidateRegexp: String?
    let nameStyle: Params.NameStyle?
}

struct ImagesProcessor: AssetsProcessable {
    typealias AssetType = ImagePack

    let platform: Platform
    let nameValidateRegexp: String?
    let nameStyle: Params.NameStyle?
}

extension AssetsProcessable {

    func process(light: [AssetType], dark: [AssetType]?) -> ProcessingPairResult {
        if let dark = dark {
            return validateAndMakePairs(
                light: normalizeAssetName(assets: light),
                dark: normalizeAssetName(assets: dark)
            )
        } else {
            return validateAndMakePairs(
                light: normalizeAssetName(assets: light)
            )
        }
    }
    
    func process(assets: [AssetType]) -> ProcessingResult {
        let assets = normalizeAssetName(assets: assets)
        return validateAndProcess(assets: assets)
    }
    
    private func validateAndProcess(assets: [AssetType]) -> ProcessingResult {
        var errors = ErrorGroup()

        // foundDuplicate
        var set: Set<AssetType> = []
        assets.forEach { asset in

            // badName
            if !isNameValid(asset.name) {
                errors.all.append(AssetsValidatorError.badName(name: asset.name))
            }

            switch set.insert(asset) {
            case (true, _):
                break // ok
            case (false, let oldMember): // already exists
                errors.all.append(AssetsValidatorError.foundDuplicate(assetName: oldMember.name))
            }
        }

        if !errors.all.isEmpty {
            return .failure(errors)
        }
        
        let assets = set
            .sorted { $0.name < $1.name }
            .filter { $0.platform == nil || $0.platform == platform }
            .map { asset -> AssetType in
                var newAsset = asset
                if let style = nameStyle {
                    newAsset.name = self.normalizeName(newAsset.name, style: style)
                }
                return newAsset
            }
        
        return .success(assets)
    }

    private func validateAndMakePairs(light: [AssetType]) -> ProcessingPairResult {
        var errors = ErrorGroup()

        // foundDuplicate
        var lightSet: Set<AssetType> = []
        light.forEach { asset in

            // badName
            if !isNameValid(asset.name) {
                errors.all.append(AssetsValidatorError.badName(name: asset.name))
            }

            switch lightSet.insert(asset) {
            case (true, _):
                break // ok
            case (false, let oldMember): // already exists
                errors.all.append(AssetsValidatorError.foundDuplicate(assetName: oldMember.name))
            }
        }

        if !errors.all.isEmpty {
            return .failure(errors)
        }

        let pairs = makeSortedAssetPairs(lightSet: lightSet)
        return .success(pairs)
    }

    private func validateAndMakePairs(light: [AssetType], dark: [AssetType]) -> ProcessingPairResult {
        var errors = ErrorGroup()

        // 1. countMismatch
        if light.count != dark.count {
            errors.all.append(AssetsValidatorError.countMismatch(light: light.count, dark: dark.count))
        }

        // 2. foundDuplicate
        var lightSet: Set<AssetType> = []
        light.forEach { asset in

            // badName
            if !isNameValid(asset.name) {
                errors.all.append(AssetsValidatorError.badName(name: asset.name))
            }

            switch lightSet.insert(asset) {
            case (true, _):
                break // ok
            case (false, let oldMember): // already exists
                errors.all.append(AssetsValidatorError.foundDuplicate(assetName: oldMember.name))
            }
        }

        var darkSet: Set<AssetType> = []
        dark.forEach { asset in
            switch darkSet.insert(asset) {
            case (true, _):
                break // ok
            case (false, let oldMember): // already exists
                errors.all.append(AssetsValidatorError.foundDuplicate(assetName: oldMember.name))
            }
        }

        // 3. lightAssetNotFoundInDarkPalette

        let lightElements = lightSet.subtracting(darkSet)
        if !lightElements.isEmpty {
            errors.all.append(AssetsValidatorError.lightAssetsNotFoundInDarkPalette(assets: lightElements.map { $0.name }))
        }

        // 4. darkAssetNotFoundInLightPalette
        let darkElements = darkSet.subtracting(lightSet)
        if !darkElements.isEmpty {
            errors.all.append(AssetsValidatorError.darkAssetsNotFoundInLightPalette(assets: darkElements.map { $0.name }))
        }

        // 5. descriptionMismatch
        lightSet.forEach { asset in
            if let platform = asset.platform {
                let dark = darkSet.first(where: { $0.name == asset.name })
                if dark?.platform != platform {
                    errors.all.append(AssetsValidatorError.descriptionMismatch(assetName: asset.name, light: platform.rawValue, dark: dark?.platform?.rawValue ?? ""))
                }
            }
        }

        if !errors.all.isEmpty {
            return .failure(errors)
        }

        let pairs = makeSortedAssetPairs(lightSet: lightSet, darkSet: darkSet)
        return .success(pairs)
    }
    
    private func makeSortedAssetPairs(lightSet: Set<AssetType>) -> [AssetPair<Self.AssetType>] {
        return lightSet
            .sorted { $0.name < $1.name }
            .filter { $0.platform == nil || $0.platform == platform }
            .map { lightAsset -> AssetPair<AssetType> in

                var newLightAsset = lightAsset

                if let style = nameStyle {
                    newLightAsset.name = self.normalizeName(lightAsset.name, style: style)
                }

                return AssetPair(light: newLightAsset, dark: nil)
            }
    }

    private func makeSortedAssetPairs(
        lightSet: Set<AssetType>,
        darkSet: Set<AssetType>) -> [AssetPair<Self.AssetType>] {

        let lightColors = lightSet
            .filter { $0.platform == platform || $0.platform == nil }
            .sorted { $0.name < $1.name }

        let darkColors = darkSet
            .filter { $0.platform == platform || $0.platform == nil }
            .sorted { $0.name < $1.name }

        let zipResult = zip(lightColors, darkColors)

        return zipResult
            .map { lightAsset, darkAsset in

                var newLightAsset = lightAsset
                var newDarkAsset = darkAsset

                if let style = nameStyle {
                    newLightAsset.name = self.normalizeName(lightAsset.name, style: style)
                    newDarkAsset.name = self.normalizeName(darkAsset.name, style: style)
                }

                return AssetPair(light: newLightAsset, dark: newDarkAsset)
            }
    }
    
    /// Normalizes asset name by replacing "/" with "_" and by removing duplication (e.g. "color/color" becomes "color"
    private func normalizeAssetName(assets: [AssetType]) -> [AssetType] {
        assets.map { asset -> AssetType in
            
            var renamedAsset = asset
            
            let split = asset.name.split(separator: "/")
            if split.count == 2, split[0] == split[1] {
                renamedAsset.name = String(split[0])
            } else {
                renamedAsset.name = renamedAsset.name.replacingOccurrences(of: "/", with: "_")
            }
            return renamedAsset
        }
    }
}
