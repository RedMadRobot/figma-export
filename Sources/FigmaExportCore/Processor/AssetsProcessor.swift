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

public struct TypographyProcessor: AssetsProcessable {
    public typealias AssetType = TextStyle

    public let platform: Platform
    public let nameValidateRegexp: String?
    public let nameReplaceRegexp: String?
    public let nameStyle: NameStyle?

    public init(platform: Platform, nameValidateRegexp: String?, nameReplaceRegexp: String?, nameStyle: NameStyle?) {
        self.platform = platform
        self.nameValidateRegexp = nameValidateRegexp
        self.nameReplaceRegexp = nameReplaceRegexp
        self.nameStyle = nameStyle
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

    public var description: String {
        "ImagesProcessor(nameValidateRegexp: \(nameValidateRegexp)"
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
            .map { processedAssetName($0) }
        
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
            if
                let platform = asset.platform,
                let dark = darkSet.first(where: { $0.name == asset.name }),
                dark.platform != platform {
                
                let error = AssetsValidatorError.descriptionMismatch(
                    assetName: asset.name,
                    light: platform.rawValue,
                    dark: dark.platform?.rawValue ?? "")
                
                errors.all.append(error)
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
            .map { AssetPair(light: processedAssetName($0), dark: nil) }
    }

    private func makeSortedAssetPairs(
        lightSet: Set<AssetType>,
        darkSet: Set<AssetType>) -> [AssetPair<Self.AssetType>] {

        let lightAssets = lightSet
            .filter { $0.platform == platform || $0.platform == nil }
            .sorted { $0.name < $1.name }

        // After validations, only those dark assets in the light asset set are allowed
        // However the dark array may be smaller than the light array
        // Create a same size array of dark assets so we can zip in the next step
        let darkAssetMap: [String: AssetType] = darkSet.reduce(into: [:]) { $0[$1.name] = $1 }
        let darkAssets = lightAssets.map { lightAsset in darkAssetMap[lightAsset.name] }

        let zipResult = zip(lightAssets, darkAssets)

        return zipResult
            .map { lightAsset, darkAsset in
                AssetPair(
                    light: processedAssetName(lightAsset),
                    dark: darkAsset.map { processedAssetName($0) }
                )
            }
    }

    /// Runs the name replacement and name validation regexps, and name styles, if they are defined
    /// - Returns:
    ///   - `AssetType` with a processed name
    private func processedAssetName(_ asset: AssetType) -> AssetType {
        var newAsset = asset

        if let replaceRegExp = nameReplaceRegexp, let regexp = nameValidateRegexp {
            newAsset.name = replace(newAsset.name, matchRegExp: regexp, replaceRegExp: replaceRegExp)
        }

        if let style = nameStyle {
            newAsset.name = normalizeName(newAsset.name, style: style)
        }

        return newAsset
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
