public extension Double {
    var floatingPointFixed: Double {
        (self * 1000).rounded() / 1000
    }
}
