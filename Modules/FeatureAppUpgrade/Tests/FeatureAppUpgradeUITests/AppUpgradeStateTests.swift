// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAppUpgradeDomain
@testable import FeatureAppUpgradeUI
import XCTest

class AppUpgradeStateTests: XCTestCase {

    func testUnsupportedOS() {
        let url = "example.com"
        let minimumOSVersion = "2.0"
        let currentOSVersion = "1.0"
        let data = AppUpgradeData(
            appStoreVersion: "",
            bannedVersions: [],
            minimumAppVersion: "",
            minimumOSVersion: minimumOSVersion,
            redirectToWebsite: false,
            sitewideMaintenance: false,
            softUpgradeVersion: "",
            statusURL: "",
            storeURI: "",
            websiteURL: url
        )
        let state = AppUpgradeState(data: data, appVersion: "", currentOSVersion: currentOSVersion)
        XCTAssertEqual(state, AppUpgradeState(style: .unsupportedOS, url: url))
    }

    func testSiteWideMaintenance() {
        let url = "example.com"
        let data = AppUpgradeData(
            appStoreVersion: "",
            bannedVersions: [],
            minimumAppVersion: "",
            minimumOSVersion: "",
            redirectToWebsite: false,
            sitewideMaintenance: true,
            softUpgradeVersion: "",
            statusURL: url,
            storeURI: "",
            websiteURL: ""
        )
        let state = AppUpgradeState(data: data, appVersion: "", currentOSVersion: "")
        XCTAssertEqual(state, AppUpgradeState(style: .maintenance, url: url))
    }

    func testRedirectToWebsite() {
        let url = "example.com"
        let data = AppUpgradeData(
            appStoreVersion: "",
            bannedVersions: [],
            minimumAppVersion: "",
            minimumOSVersion: "",
            redirectToWebsite: true,
            sitewideMaintenance: false,
            softUpgradeVersion: "",
            statusURL: "",
            storeURI: "",
            websiteURL: url
        )
        let state = AppUpgradeState(data: data, appVersion: "", currentOSVersion: "")
        XCTAssertEqual(state, AppUpgradeState(style: .appMaintenance, url: url))
    }

    func testAppVersionIsBannedAndNoUpdateIsAvailable() {
        let url = "example.com"
        let bannedVersion = "2.0"
        let data = AppUpgradeData(
            appStoreVersion: bannedVersion,
            bannedVersions: [bannedVersion],
            minimumAppVersion: "",
            minimumOSVersion: "",
            redirectToWebsite: false,
            sitewideMaintenance: false,
            softUpgradeVersion: "",
            statusURL: "",
            storeURI: "",
            websiteURL: url
        )
        let state = AppUpgradeState(data: data, appVersion: bannedVersion, currentOSVersion: "")
        XCTAssertEqual(state, AppUpgradeState(style: .appMaintenance, url: url))
    }

    func testAppVersionIsBannedAndUpdateIsAvailable() {
        let url = "example.com"
        let bannedVersion = "2.0"
        let appStoreVersion = "2.1"
        let data = AppUpgradeData(
            appStoreVersion: appStoreVersion,
            bannedVersions: [bannedVersion],
            minimumAppVersion: "",
            minimumOSVersion: "",
            redirectToWebsite: false,
            sitewideMaintenance: false,
            softUpgradeVersion: "",
            statusURL: "",
            storeURI: url,
            websiteURL: ""
        )
        let state = AppUpgradeState(data: data, appVersion: bannedVersion, currentOSVersion: "")
        XCTAssertEqual(state, AppUpgradeState(style: .hardUpgrade, url: url))
    }

    func testAppVersionIsLessThanMinimum() {
        let url = "example.com"
        let appVersion = "1.0"
        let minimumAppVersion = "2.0"
        let data = AppUpgradeData(
            appStoreVersion: "",
            bannedVersions: [],
            minimumAppVersion: minimumAppVersion,
            minimumOSVersion: "",
            redirectToWebsite: false,
            sitewideMaintenance: false,
            softUpgradeVersion: "",
            statusURL: "",
            storeURI: url,
            websiteURL: ""
        )
        let state = AppUpgradeState(data: data, appVersion: appVersion, currentOSVersion: "")
        XCTAssertEqual(state, AppUpgradeState(style: .hardUpgrade, url: url))
    }

    func testAppVersionIsLessThanSoftMinimum() {
        let url = "example.com"
        let appVersion = "1.0"
        let softUpgradeVersion = "2.0"
        let data = AppUpgradeData(
            appStoreVersion: "",
            bannedVersions: [],
            minimumAppVersion: "",
            minimumOSVersion: "",
            redirectToWebsite: false,
            sitewideMaintenance: false,
            softUpgradeVersion: softUpgradeVersion,
            statusURL: "",
            storeURI: url,
            websiteURL: ""
        )
        let state = AppUpgradeState(data: data, appVersion: appVersion, currentOSVersion: "")
        XCTAssertEqual(state, AppUpgradeState(style: .softUpgrade, url: url))
    }

    func testNoActionNeeded() {
        let url = "example.com"
        let appVersion = "1.0"
        let data = AppUpgradeData(
            appStoreVersion: "",
            bannedVersions: [],
            minimumAppVersion: "",
            minimumOSVersion: "1.0",
            redirectToWebsite: false,
            sitewideMaintenance: false,
            softUpgradeVersion: "",
            statusURL: "",
            storeURI: "",
            websiteURL: url
        )
        let state = AppUpgradeState(data: data, appVersion: appVersion, currentOSVersion: "1.0")
        XCTAssertNil(state)
    }
}
