// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct AppUpgradeData: Equatable, Decodable {
    /// Most recent app version available in the App Store.
    public let appStoreVersion: String
    /// Array of banned app versions.
    /// If running app version is contained in this array, hard upgrade flow should start.
    public let bannedVersions: [String]
    /// The minimum app version.
    /// If running app version is less than this, hard upgrade flow should start.
    public let minimumAppVersion: String
    /// The minimum OS version.
    /// If device OS is less than this, hard upgrade flow should start.
    public let minimumOSVersion: String

    /// Redirect to website status.
    /// If true, down for maintenance flow should start with websiteURL link.
    public let redirectToWebsite: Bool

    /// Site-wide maintenance status.
    /// If true, down for maintenance flow should start with statusURL link.
    public let sitewideMaintenance: Bool

    /// Soft upgrade version.
    /// If running app version is less than this, soft upgrade flow should start.
    public let softUpgradeVersion: String

    /// Status web page URL.
    /// https://status.blockchain.com
    public let statusURL: String

    /// App Store URI.
    /// itms-apps://itunes.apple.com/app/id493253309
    public let storeURI: String

    /// Web page URL.
    /// https://www.blockchain.com
    public let websiteURL: String

    public init(
        appStoreVersion: String,
        bannedVersions: [String],
        minimumAppVersion: String,
        minimumOSVersion: String,
        redirectToWebsite: Bool,
        sitewideMaintenance: Bool,
        softUpgradeVersion: String,
        statusURL: String,
        storeURI: String,
        websiteURL: String
    ) {
        self.appStoreVersion = appStoreVersion
        self.bannedVersions = bannedVersions
        self.minimumAppVersion = minimumAppVersion
        self.minimumOSVersion = minimumOSVersion
        self.redirectToWebsite = redirectToWebsite
        self.sitewideMaintenance = sitewideMaintenance
        self.softUpgradeVersion = softUpgradeVersion
        self.statusURL = statusURL
        self.storeURI = storeURI
        self.websiteURL = websiteURL
    }
}
