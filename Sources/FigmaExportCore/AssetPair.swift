public struct AssetPair<AssetType> where AssetType: Asset {
    
    public let light: AssetType
    public let dark: AssetType?
    
    public init(light: AssetType, dark: AssetType?) {
        self.light = light
        self.dark = dark
    }
}
