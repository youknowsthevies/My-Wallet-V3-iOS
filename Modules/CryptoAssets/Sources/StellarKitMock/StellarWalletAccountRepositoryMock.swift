// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import PlatformKit
import StellarKit

class StellarWalletAccountRepositoryMock: StellarWalletAccountRepositoryAPI {

    var defaultAccount: AnyPublisher<StellarWalletAccount?, StellarWalletAccountRepositoryError> = .empty()

    func initializeMetadataMaybe() -> AnyPublisher<StellarWalletAccount, StellarWalletAccountRepositoryError> {
        .empty()
    }

    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        .empty()
    }

    func loadKeyPair(
        with secondPassword: String?
    ) -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        .empty()
    }
}
