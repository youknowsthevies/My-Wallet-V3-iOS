// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

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

extension Bundle {

    public func url(for resource: (name: String, extension: String)) -> URL? {
        url(forResource: resource.name, withExtension: resource.extension)
    }
}

extension String {

    public var fileNameAndExtension: (name: String, extension: String) {
        guard let extIndex = lastIndex(of: ".") else { return (self, "") }
        return (String(self[..<extIndex]), String(self[extIndex...]))
    }
}
