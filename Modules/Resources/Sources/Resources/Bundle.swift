// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

private class BundleFinder {}
extension Bundle {
    public static let resources = Bundle.find("Resources_Resources.bundle", in: BundleFinder.self)
}

extension Foundation.Bundle {

    /// Returns the resource bundle associated with a Swift module.
    public static func find(_ bundleName: String, in type: AnyObject.Type) -> Bundle {

        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: type).resourceURL,

            // For command-line tools.
            Bundle.main.bundleURL,

            // For SwiftUI previews
            Bundle(for: type).resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
                .deletingLastPathComponent(),

            Bundle(for: type).resourceURL?
                .deletingLastPathComponent()
                .deletingLastPathComponent()
        ]

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName)
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        fatalError("unable to find bundle named \(bundleName)")
    }
}
