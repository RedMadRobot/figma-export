public struct AssetPair<AssetType> where AssetType: Asset {
    
    public let light: AssetType
    public let dark: AssetType?
    
    public init(light: AssetType, dark: AssetType?) {
        self.light = light
        self.dark = dark
    }
    
    public static func makePairs(light: [AssetType], dark: [AssetType]?) -> [AssetPair<AssetType>] {
        guard let dark = dark else {
            return light.map { AssetPair<AssetType>(light: $0, dark: nil)}
        }
        var assetPairs: [AssetPair] = []
        
        for lightAsset in light {
            let darkAsset = dark.first { color -> Bool in
                color.name == lightAsset.name
            }
            if let darkAsset = darkAsset {
                assetPairs.append(AssetPair<AssetType>(light: lightAsset, dark: darkAsset))
            }
        }
                
        assetPairs.sort { $0.light.name < $1.light.name }
        
        return assetPairs
    }
}
