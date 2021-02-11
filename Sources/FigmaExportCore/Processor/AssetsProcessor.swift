import Foundation

/// Process asset name
public protocol AssetNameProcessable {
    
    var nameReplaceRegexp: String? { get }
    var nameValidateRegexp: String? { get }
    var nameStyle: NameStyle? { get }
    
    func isNameValid(_ name: String) -> Bool
    func normalizeName(_ name: String, style: NameStyle) -> String
}

public extension AssetNameProcessable {
    
    func isNameValid(_ name: String) -> Bool {
        if let regexp = nameValidateRegexp {
            return name.range(of: regexp, options: .regularExpression) != nil
        } else {
            return true
        }
    }
    
    func normalizeName(_ name: String, style: NameStyle) -> String {
        switch style {
        case .camelCase:
            return name.lowerCamelCased()
        case .snakeCase:
            return name.snakeCased()
        }
    }
}

public struct AssetResult<Success, Error> {
    public var result: Result<Success, Swift.Error>
    public var warning: AssetsValidatorWarning?

    public func get() throws -> Success {
        return try result.get()
    }

    public static func failure(_ error: Swift.Error) -> AssetResult<Success, Error> {
        return AssetResult(result: .failure(error), warning: nil)
    }

    public static func success(_ data: Success) -> AssetResult<Success, Error> {
        return AssetResult(result: .success(data), warning: nil)
    }

    public static func success(_ data: Success, warning: AssetsValidatorWarning?) -> AssetResult<Success, Error> {
        return AssetResult(result: .success(data), warning: warning)
    }
}

public protocol AssetsProcessable: AssetNameProcessable {
    associatedtype AssetType: Asset
    typealias ProcessingPairResult = AssetResult<[AssetPair<AssetType>], ErrorGroup>
    typealias ProcessingResult = AssetResult<[AssetType], ErrorGroup>
    
    var platform: Platform { get }
    
    func process(light: [AssetType], dark: [AssetType]?) -> ProcessingPairResult
    func process(assets: [AssetType]) -> ProcessingResult
}

public struct ColorsProcessor: AssetsProcessable {
    public typealias AssetType = Color
    
    public let platform: Platform
    public let nameValidateRegexp: String?
    public let nameReplaceRegexp: String?
    public let nameStyle: NameStyle?
    public let useSingleFile: Bool?
    public let darkModeSuffix: String?
    
    public init(platform: Platform, nameValidateRegexp: String?, nameReplaceRegexp: String?, nameStyle: NameStyle?, useSingleFile: Bool?, darkModeSuffix: String?) {
        self.platform = platform
        self.nameValidateRegexp = nameValidateRegexp
        self.nameReplaceRegexp = nameReplaceRegexp
        self.nameStyle = nameStyle
        self.useSingleFile = useSingleFile
        self.darkModeSuffix = darkModeSuffix
    }
}

public struct ImagesProcessor: AssetsProcessable {
    public typealias AssetType = ImagePack

    public let platform: Platform
    public let nameValidateRegexp: String?
    public let nameReplaceRegexp: String?
    public let nameStyle: NameStyle?
    
    public init(platform: Platform, nameValidateRegexp: String? = nil, nameReplaceRegexp: String? = nil, nameStyle: NameStyle?) {
        self.platform = platform
        self.nameValidateRegexp = nameValidateRegexp
        self.nameReplaceRegexp = nameReplaceRegexp
        self.nameStyle = nameStyle
    }
}

public extension AssetsProcessable {

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
                if let replaceRegExp = nameReplaceRegexp, let regexp = nameValidateRegexp {
                    newAsset.name = self.replace(newAsset.name, matchRegExp: regexp, replaceRegExp: replaceRegExp)
                }
                if let style = nameStyle {
                    newAsset.name = self.normalizeName(newAsset.name, style: style)
                }
                return newAsset
            }
        
        return .success(assets)
    }
    
    private func replace(_ name: String, matchRegExp: String, replaceRegExp: String) -> String {
        let result = name.replace(matchRegExp) { array in
            replaceRegExp.replace(#"\$(\d)"#) {
                let index = Int($0[1])!
                return array[index]
            }
        }
        
        return result
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

        // Error checks

        var errors = ErrorGroup()

        // 1. countMismatch
        if light.count < dark.count {
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

        // 3. darkAssetNotFoundInLightPalette
        let darkElements = darkSet.subtracting(lightSet)
        if !darkElements.isEmpty {
            errors.all.append(AssetsValidatorError.darkAssetsNotFoundInLightPalette(assets: darkElements.map { $0.name }))
        }

        // 4. descriptionMismatch
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

        // Warning checks

        var warning: AssetsValidatorWarning?

        // 1. lightAssetNotFoundInDarkPalette
        let lightElements = lightSet.subtracting(darkSet)
        if !lightElements.isEmpty {
            warning = .lightAssetsNotFoundInDarkPalette(assets: lightElements.map { $0.name })
        }

        let pairs = makeSortedAssetPairs(lightSet: lightSet, darkSet: darkSet)
        return .success(pairs, warning: warning)
    }
    
    private func makeSortedAssetPairs(lightSet: Set<AssetType>) -> [AssetPair<Self.AssetType>] {
        return lightSet
            .sorted { $0.name < $1.name }
            .filter { $0.platform == nil || $0.platform == platform }
            .map { lightAsset -> AssetPair<AssetType> in

                var newLightAsset = lightAsset

                if let replaceRegExp = nameReplaceRegexp, let regexp = nameValidateRegexp {
                    newLightAsset.name = self.replace(newLightAsset.name, matchRegExp: regexp, replaceRegExp: replaceRegExp)
                }
                
                if let style = nameStyle {
                    newLightAsset.name = self.normalizeName(newLightAsset.name, style: style)
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

        // After validations, only those dark colors in the light color palette are allowed
        // However the dark array may be smaller than the light array
        // Create a same size array of dark colors so we can zip in the next step
        let darkColorMap: [String: AssetType] = darkSet.reduce(into: [:]) { $0[$1.name] = $1 }
        let darkColors = lightColors
            .map { lightColor in darkColorMap[lightColor.name] }

        let zipResult = zip(lightColors, darkColors)

        return zipResult
            .map { lightAsset, darkAsset in

                var newLightAsset = lightAsset
                var newDarkAsset = darkAsset

                if let replaceRegExp = nameReplaceRegexp, let regexp = nameValidateRegexp {
                    newLightAsset.name = self.replace(newLightAsset.name, matchRegExp: regexp, replaceRegExp: replaceRegExp)
                    newDarkAsset?.name = self.replace(darkAsset?.name ?? "", matchRegExp: regexp, replaceRegExp: replaceRegExp)
                }
                
                if let style = nameStyle {
                    newLightAsset.name = self.normalizeName(newLightAsset.name, style: style)
                    newDarkAsset?.name = self.normalizeName(darkAsset?.name ?? "", style: style)
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
