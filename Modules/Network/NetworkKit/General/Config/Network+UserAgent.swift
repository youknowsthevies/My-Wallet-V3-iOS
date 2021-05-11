// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// TODO: Add `AppVersion` getter to Bundle for a more convenient access as it is used in several other placed, causing duplication of identical code
@objc
extension Bundle {
    /// The application version. Equivalent to CFBundleShortVersionString.
    public static var applicationVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let version = infoDictionary["CFBundleShortVersionString"] as? String else {
            return nil
        }
        return version
    }
    /// The build version of the application. Equivalent to CFBundleVersion.
    public static var applicationBuildVersion: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let buildVersion = infoDictionary["CFBundleVersion"] as? String else {
            return nil
        }
        return buildVersion
    }
    /// The build version of the application. Equivalent to CFBundleDisplayName.
    public static var applicationName: String? {
        guard let infoDictionary = main.infoDictionary else {
            return nil
        }
        guard let appName = infoDictionary["CFBundleDisplayName"] as? String else {
            return nil
        }
        return appName
    }
}
