// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

@testable import Blockchain

class MockWallet: Wallet {

    var mockIsInitialized: Bool = false

    override func isInitialized() -> Bool {
        mockIsInitialized
    }

    var mockNeedsSecondPassword = false

    override func needsSecondPassword() -> Bool {
        mockNeedsSecondPassword
    }

    var guid: String = ""
    var sharedKey: String?
    private var password: String?

    /// When called, invokes the delegate's walletDidDecrypt and walletDidFinishLoad methods
    override func load(withGuid guid: String, sharedKey: String?, password: String?) {
        delegate?.walletDidDecrypt?(withSharedKey: sharedKey, guid: guid)
        delegate?.walletDidFinishLoad?()
    }

    var fetchCalled = false

    override func fetch(with password: String) {
        fetchCalled = true
        self.password = password
    }

    var getHistoryForAllAssetsCalled = false

    override func getHistoryForAllAssets() {
        getHistoryForAllAssetsCalled = true
    }
}
