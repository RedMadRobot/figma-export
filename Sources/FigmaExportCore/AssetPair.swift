public struct AssetPair<AssetType> where AssetType: Asset {
    
    public let light: AssetType
    public let dark: AssetType?
    public var lightHC: AssetType?
    public var darkHC: AssetType?
    
    public init(
        light: AssetType,
        dark: AssetType?,
        lightHC: AssetType? = nil,
        darkHC: AssetType? = nil
    ) {
        self.light = light
        self.dark = dark
        self.lightHC = lightHC
        self.darkHC = darkHC
    }

    public mutating func setLightHC(_ lightHC: AssetType?) {
        self.lightHC = lightHC
    }

    public mutating func setDarkHC(_ darkHC: AssetType?) {
        self.darkHC = darkHC
    }
}
