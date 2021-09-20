// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
@testable import EthereumKit
import Foundation
import PlatformKit
import RxSwift

final class EthereumWalletAccountRepositoryMock: EthereumWalletAccountRepositoryAPI, KeyPairProviderAPI {

    static let mockEthereumWalletAccount = EthereumWalletAccount(
        index: 0,
        publicKey: "",
        label: "",
        archived: false
    )

    var keyPairValue = Single.just(MockEthereumWalletTestData.keyPair)
    var keyPair: Single<EthereumKeyPair> {
        keyPairValue
    }

    func keyPair(with secondPassword: String?) -> Single<EthereumKeyPair> {
        keyPairValue
    }

    var underlyingDefaultAccount: EthereumWalletAccount = mockEthereumWalletAccount
    var defaultAccount: AnyPublisher<EthereumWalletAccount, WalletAccountRepositoryError> {
        .just(underlyingDefaultAccount)
    }
}
