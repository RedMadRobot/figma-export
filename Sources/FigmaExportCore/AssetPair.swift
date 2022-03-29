public struct AssetPair<AssetType> where AssetType: Asset {
    
    public let light: AssetType
    public let dark: AssetType?
    public let lightHC: AssetType?
    public let darkHC: AssetType?
    
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
}
