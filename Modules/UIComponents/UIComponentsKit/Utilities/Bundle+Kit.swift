import Foundation

extension Bundle {
    
    static var current: Bundle {
        class BundleFinder {}
        return Bundle(for: BundleFinder.self)
    }
}
