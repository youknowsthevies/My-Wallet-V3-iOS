// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

final class WalletOptionsVersionUpdateTests: XCTestCase {

    func testNoUpdate() throws {
        let expected: WalletOptions.UpdateType = .none
        let walletOptions = try walletOptions(updateType: expected.rawValue, version: "")
        XCTAssertEqual(expected, walletOptions.updateType)
    }

    func testMissingUpdateTypeFailure() throws {
        let expected: WalletOptions.UpdateType = .none
        let walletOptions = try walletOptions(updateType: "", version: "")
        XCTAssertEqual(expected, walletOptions.updateType)
    }

    func testUpdateTypeRecommendedWhileLatestVersionMissing() throws {
        let expected: WalletOptions.UpdateType = .none
        let walletOptions = try walletOptions(updateType: WalletOptions.UpdateType.RawValue.forced, version: "")
        XCTAssertEqual(expected, walletOptions.updateType)
    }

    func testUpdateTypeForcedWhileLatestVersionMissing() throws {
        let expected: WalletOptions.UpdateType = .none
        let walletOptions = try walletOptions(updateType: WalletOptions.UpdateType.RawValue.recommended, version: "")
        XCTAssertEqual(expected, walletOptions.updateType)
    }

    func testUpdateTypeRecommendedWithLatestVersion() throws {
        let expected: WalletOptions.UpdateType = .recommended(
            latestVersion: .init(major: 1, minor: 2, patch: 3)
        )
        let walletOptions = try walletOptions(updateType: expected.rawValue, version: "1.2.3")
        XCTAssertEqual(expected, walletOptions.updateType)
    }

    func testWalletOptionsDecodeToDefaultValuesIfResponseIsEmpty() {
        XCTAssertNoThrow(try JSONDecoder().decode(WalletOptions.self, from: "{}".data(using: .utf8)!))
    }

    // MARK: - Private

    private func walletOptions(updateType: String, version: String) throws -> WalletOptions {
        let json =
            """
            {
                "ios":
                {
                    "update":
                    {
                        "updateType": "\(updateType)",
                        "latestStoreVersion": "\(version)"
                    }
                }
            }
            """
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(WalletOptions.self, from: data)
    }
}
