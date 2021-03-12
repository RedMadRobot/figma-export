public enum Drawable {
    
    public static func scaleToDrawableName(_ scale: Double, dark: Bool, singleScale: Bool) -> String {
        if singleScale {
            return dark ? "drawable-night" : "drawable"
        }
        switch scale {
        case 1:
            return dark ? "drawable-night-mdpi" : "drawable-mdpi"
        case 1.5:
            return dark ? "drawable-night-hdpi" : "drawable-hdpi"
        case 2:
            return dark ? "drawable-night-xhdpi" : "drawable-xhdpi"
        case 3:
            return dark ? "drawable-night-xxhdpi" : "drawable-xxhdpi"
        case 4:
            return dark ? "drawable-night-xxxhdpi" : "drawable-xxxhdpi"
        default:
            fatalError("Unknown scale \(scale)")
        }
    }
}
