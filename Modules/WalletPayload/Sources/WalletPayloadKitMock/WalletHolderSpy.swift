// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadDataKit
import WalletPayloadKit

final class WalletHolderSpy: WalletHolderAPI {

    var walletStatePublisherCalled: Bool = false
    var holdWalletCalled: (Bool, WalletState?) = (false, nil)
    var provideWalletStateCalled: (Bool, WalletState?) = (false, nil)

    var releaseCalled: Bool = false

    var walletStatePublisher: AnyPublisher<WalletState?, Never> {
        walletStatePublisherCalled = true
        return spyOn.walletStatePublisher
    }

    private let spyOn: WalletHolderAPI

    init(spyOn: WalletHolderAPI) {
        self.spyOn = spyOn
    }

    func provideWalletState() -> WalletState? {
        let state = spyOn.provideWalletState()
        provideWalletStateCalled = (true, state)
        return state
    }

    func hold(walletState: WalletState) -> AnyPublisher<WalletState, Never> {
        holdWalletCalled = (true, walletState)
        return spyOn.hold(walletState: walletState)
    }

    func release() {
        releaseCalled = false
        spyOn.release()
    }
}
