// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Bundle {

    public var plist: InfoPlist! { try? InfoPlist(in: self) }

    /// Provides the builder number and version using this format:
    /// - Production builds: v1.0.0 (1)
    /// - Internal builds: v1.0.0 (commit hash)
    /// - Returns: A `String` representing the build number
    public static func versionAndBuildNumber() -> String {
        let plist: InfoPlist = MainBundleProvider.mainBundle.plist
        let hash = plist.COMMIT_HASH as? String ?? ""
        var title = "v\(plist.version)"
        if BuildFlag.isInternal {
            title = "\(title) (\(hash))"
        } else {
            title = "\(title) (\(plist.build))"
        }
        return title
    }

    /// The application version. Equivalent to CFBundleShortVersionString.
    public static var applicationVersion: String? {
        main.plist.version.description
    }

    /// The build version of the application. Equivalent to CFBundleVersion.
    public static var applicationBuildVersion: String? {
        main.plist.build
    }

    /// The name of the application. Equivalent to CFBundleDisplayName.
    public static var applicationName: String? {
        main.plist.name
    }
}

@dynamicMemberLookup
public struct InfoPlist {

    public var version: Version
    public var build: String
    public var name: String

    private let source: [String: Any]

    public init(source: [String: Any]) throws {
        self.source = source
        version = try Version(
            string: source["CFBundleShortVersionString"]
                .as(String.self)
                .or(throw: Error.missing(key: "CFBundleShortVersionString"))
        )
        build = try source["CFBundleVersion"]
            .as(String.self)
            .or(throw: Error.missing(key: "CFBundleVersion"))
        name = try source["CFBundleDisplayName"]
            .as(String.self)
            .or(throw: Error.missing(key: "CFBundleDisplayName"))
    }

    public subscript(dynamicMember string: String) -> Any? {
        source[string]
    }
}

extension InfoPlist {

    public init(in bundle: Bundle = Bundle.main) throws {
        guard let source = bundle.infoDictionary else {
            throw Error.missingInfoDictionary
        }
        self = try .init(source: source)
    }

    public enum Error: Swift.Error {
        case missingInfoDictionary
        case missing(key: String)
    }
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
