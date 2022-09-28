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
    
    func process(light: [AssetType], dark: [AssetType]?, lightHC: [AssetType]?, darkHC: [AssetType]?) -> ProcessingPairResult
    func process(assets: [AssetType]) -> ProcessingResult
}

public struct ColorsProcessor: AssetsProcessable {
    public typealias AssetType = Color
    
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

public struct SpacingsProcessor: AssetsProcessable {
    public typealias AssetType = Spacing

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
}

public extension AssetsProcessable {

    func process(light: [AssetType],
                 dark: [AssetType]?,
                 lightHC: [AssetType]? = nil,
                 darkHC: [AssetType]? = nil) -> ProcessingPairResult {
        guard let dark = dark else { return lightProcess(light: light, lightHC: lightHC) }
        return darkProcess(light: light, dark: dark, lightHC: lightHC, darkHC: darkHC)
    }

    private func lightProcess(light: [AssetType], lightHC: [AssetType]?) -> ProcessingPairResult {
        return validateAndMakePairs(light: normalizeAssetName(light),
                                    lightHighContrast: normalizeAssetName(lightHC ?? []))
    }

    private func darkProcess(light: [AssetType],
                             dark: [AssetType],
                             lightHC: [AssetType]?,
                             darkHC: [AssetType]?) -> ProcessingPairResult {
        return validateAndMakePairs(light: normalizeAssetName(light),
                                    dark: normalizeAssetName(dark),
                                    lightHC: normalizeAssetName(lightHC ?? []),
                                    darkHC: normalizeAssetName(darkHC ?? []))
    }

    func process(assets: [AssetType]) -> ProcessingResult {
        let assets = normalizeAssetName(assets)
        return validateAndProcess(assets: assets)
    }

    private func validateAndMakePairs(light: [AssetType],
                                      lightHighContrast: [AssetType]) -> ProcessingPairResult {
        // Error checks
        var errors = ErrorGroup()
        // CountMismatch
        if light.count < lightHighContrast.count {
            errors.all.append(AssetsValidatorError.countMismatchLightHighContrastColors(light: light.count, lightHC: lightHighContrast.count))
        }
        // FoundDuplicate
        let lightSet: Set<AssetType> = foundDuplicate(assets: light, errors: &errors, isLightAssetSet: true)
        let lightHCSet: Set<AssetType> = foundDuplicate(assets: lightHighContrast, errors: &errors)
        // AssetNotFoundInLightPalette
        checkSubtracting(firstAssetSet: lightSet,
                         firstAssetName: "Light",
                         secondAssetSet: lightHCSet,
                         secondAssetName: "Light high contrast",
                         errors: &errors)
        // DescriptionMismatch
        lightSet.forEach { asset in
            if let platform = asset.platform,
               let dark = lightHCSet.first(where: { $0.name == asset.name }),
               dark.platform != platform {
                let error = AssetsValidatorError.descriptionMismatch(
                    assetName: asset.name,
                    light: platform.rawValue,
                    dark: dark.platform?.rawValue ?? "")
                errors.all.append(error)
            }
        }
        // Return failure
        guard errors.all.isEmpty else { return .failure(errors) }
        // Warning checks
        var warning: AssetsValidatorWarning?
        // LightAssetNotFoundInLightHCPalette
        if !lightHCSet.isEmpty {
            let lightElements = lightSet.subtracting(lightHCSet)
            if !lightElements.isEmpty { warning = .lightHCAssetsNotFoundInLightPalette(assets: lightElements.map { $0.name }) }
        }
        let pairs = makeSortedAssetPairs(lightSet: lightSet, lightHCSet: lightHCSet)
        return .success(pairs, warning: warning)
    }

    private func validateAndMakePairs(light: [AssetType],
                                      dark: [AssetType],
                                      lightHC: [AssetType],
                                      darkHC: [AssetType]) -> ProcessingPairResult {
        // Error checks
        var errors = ErrorGroup()
        // CountMismatch
        if light.count < dark.count {
            errors.all.append(AssetsValidatorError.countMismatch(light: light.count, dark: dark.count))
        }
        if light.count < lightHC.count {
            errors.all.append(AssetsValidatorError.countMismatchLightHighContrastColors(light: light.count, lightHC: lightHC.count))
        }
        if dark.count < darkHC.count {
            errors.all.append(AssetsValidatorError.countMismatchDarkHighContrastColors(dark: dark.count, darkHC: darkHC.count))
        }
        // FoundDuplicate
        let lightSet: Set<AssetType> = foundDuplicate(assets: light, errors: &errors, isLightAssetSet: true)
        let darkSet: Set<AssetType> = foundDuplicate(assets: dark, errors: &errors)
        let lightHCSet: Set<AssetType> = foundDuplicate(assets: lightHC, errors: &errors)
        let darkHCSet: Set<AssetType> = foundDuplicate(assets: darkHC, errors: &errors)
        // AssetNotFoundInLightPalette
        checkSubtracting(firstAssetSet: lightSet,
                         firstAssetName: "Light",
                         secondAssetSet: darkSet,
                         secondAssetName: "Dark",
                         errors: &errors)
        checkSubtracting(firstAssetSet: lightSet,
                         firstAssetName: "Light",
                         secondAssetSet: lightHCSet,
                         secondAssetName: "Light high contrast",
                         errors: &errors)
        checkSubtracting(firstAssetSet: darkSet,
                         firstAssetName: "Dark",
                         secondAssetSet: darkHCSet,
                         secondAssetName: "Dark high contrast",
                         errors: &errors)
        // DescriptionMismatch
        lightSet.forEach { asset in
            if let platform = asset.platform,
               let dark = darkSet.first(where: { $0.name == asset.name }),
               dark.platform != platform {
                let error = AssetsValidatorError.descriptionMismatch(
                    assetName: asset.name,
                    light: platform.rawValue,
                    dark: dark.platform?.rawValue ?? "")
                errors.all.append(error)
            }
        }
        // Return failure
        guard errors.all.isEmpty else { return .failure(errors) }
        // Warning checks
        var warning: AssetsValidatorWarning?
        // LightAssetNotFoundInDarkPalette
        let lightElements = lightSet.subtracting(darkSet)
        if !lightElements.isEmpty { warning = .lightAssetsNotFoundInDarkPalette(assets: lightElements.map { $0.name }) }
        // LightAssetNotFoundInLightHCPalette
        if !lightHCSet.isEmpty {
            let lightHCElements = lightSet.subtracting(lightHCSet)
            if !lightHCElements.isEmpty { warning = .lightHCAssetsNotFoundInLightPalette(assets: lightHCElements.map { $0.name }) }
        }
        // DarkAssetNotFoundInDarkHCPalette
        if !darkHCSet.isEmpty {
            let darkHCElements = darkSet.subtracting(darkHCSet)
            if !darkHCElements.isEmpty { warning = .darkHCAssetsNotFoundInDarkPalette(assets: darkHCElements.map { $0.name }) }
        }

        let pairs = makeSortedAssetPairs(lightSet: lightSet, darkSet: darkSet, lightHCSet: lightHCSet, darkHCSet: darkHCSet)
        return .success(pairs, warning: warning)
    }

    private func makeSortedAssetPairs(lightSet: Set<AssetType>,
                                      lightHCSet: Set<AssetType>) -> [AssetPair<Self.AssetType>] {
        let lightAssets = lightSet
            .filter { $0.platform == platform || $0.platform == nil }
            .sorted { $0.name < $1.name }
        let lightHCAssetMap: [String: AssetType] = lightHCSet.reduce(into: [:]) { $0[$1.name] = $1 }
        let lightHCAssets = lightAssets.map { lightHCAsset in lightHCAssetMap[lightHCAsset.name] }
        let zipResult = zip(lightAssets, lightHCAssets)
        return zipResult
            .map { lightAsset, lightHCAsset in
                AssetPair(
                    light: processedAssetName(lightAsset),
                    dark: nil,
                    lightHC: lightHCAsset.map { processedAssetName($0)
                    }
                )
            }
    }

    private func makeSortedAssetPairs(lightSet: Set<AssetType>,
                                      darkSet: Set<AssetType>,
                                      lightHCSet: Set<AssetType>,
                                      darkHCSet: Set<AssetType>) -> [AssetPair<Self.AssetType>] {
        let lightAssets = lightSet
            .filter { $0.platform == platform || $0.platform == nil }
            .sorted { $0.name < $1.name }

        // After validations, only those dark assets in the light asset set are allowed
        // However the dark array may be smaller than the light array
        // Create a same size array of dark assets so we can zip in the next step
        let darkAssetMap: [String: AssetType] = darkSet.reduce(into: [:]) { $0[$1.name] = $1 }
        let darkAssets = lightAssets.map { darkAsset in darkAssetMap[darkAsset.name] }
        let lightHCAssetMap: [String: AssetType] = lightHCSet.reduce(into: [:]) { $0[$1.name] = $1 }
        let lightHCAssets = lightAssets.map { lightHCAsset in lightHCAssetMap[lightHCAsset.name] }
        let darkHCAssetMap: [String: AssetType] = darkHCSet.reduce(into: [:]) { $0[$1.name] = $1 }
        let darkHCAssets = lightAssets.map { darkHCAsset in darkHCAssetMap[darkHCAsset.name] }

        let zipResult = zip(lightAssets, darkAssets, lightHCAssets, darkHCAssets)

        return zipResult
            .map { lightAsset, darkAsset, lightHCAsset, darkHCAsset in
                AssetPair(light: processedAssetName(lightAsset),
                          dark: darkAsset.map { processedAssetName($0) },
                          lightHC: lightHCAsset.map { processedAssetName($0) },
                          darkHC: darkHCAsset.map { processedAssetName($0) })
            }
    }

    private func checkSubtracting(firstAssetSet: Set<AssetType>,
                                  firstAssetName: String,
                                  secondAssetSet: Set<AssetType>,
                                  secondAssetName: String,
                                  errors: inout ErrorGroup) {
        let elements = secondAssetSet.subtracting(firstAssetSet)
        if !elements.isEmpty {
            errors.all.append(AssetsValidatorError.secondAssetsNotFoundInFirstPalette(
                assets: elements.map { $0.name }, firstAssetsName: firstAssetName, secondAssetsName: secondAssetName))
        }
    }
    
    private func validateAndProcess(assets: [AssetType]) -> ProcessingResult {
        var errors = ErrorGroup()
        // FoundDuplicate
        let set = foundDuplicate(assets: assets, errors: &errors, isLightAssetSet: true)
        // Return failure
        guard errors.all.isEmpty else { return .failure(errors) }
        let assets = set
            .sorted { $0.name < $1.name }
            .filter { $0.platform == nil || $0.platform == platform }
            .map { processedAssetName($0) }
        return .success(assets)
    }

    private func foundDuplicate(assets: [AssetType],
                                errors: inout ErrorGroup,
                                isLightAssetSet: Bool = false) -> Set<AssetType> {
        var assetSet: Set<AssetType> = []
        assets.forEach { asset in
            if isLightAssetSet == true, !isNameValid(asset.name) {
                errors.all.append(AssetsValidatorError.badName(name: asset.name))
            }
            switch assetSet.insert(asset) {
            case (true, _):
                break // ok
            case (false, let oldMember): // already exists
                errors.all.append(AssetsValidatorError.foundDuplicate(assetName: oldMember.name))
            }
        }
        return assetSet
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
    private func normalizeAssetName(_ assets: [AssetType]) -> [AssetType] {
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
