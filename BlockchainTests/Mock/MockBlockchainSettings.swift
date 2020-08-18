//
//  MockBlockchainSettings.swift
//  BlockchainTests
//
//  Created by Chris Arriola on 10/30/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

@testable import Blockchain
@testable import PlatformKit

class MockBlockchainSettingsApp: BlockchainSettings.App {
    var mockDidAttemptToRouteForAirdrop: Bool = false
    var mockDidTapOnAirdropDeepLink: Bool = false
    var mockGuid: String?
    var mockSharedKey: String?

    override init(enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        super.init()
    }

    override var guid: String? {
        get {
            mockGuid
        }
        set {
            mockGuid = newValue
        }
    }

    override var sharedKey: String? {
        get {
            mockSharedKey
        }
        set {
            mockSharedKey = newValue
        }
    }

    override var didTapOnAirdropDeepLink: Bool {
        get {
            mockDidTapOnAirdropDeepLink
        }
        set {
            mockDidTapOnAirdropDeepLink = newValue
        }
    }

    override var didAttemptToRouteForAirdrop: Bool {
        get {
            mockDidAttemptToRouteForAirdrop
        }
        set {
            mockDidAttemptToRouteForAirdrop = newValue
        }
    }
}
