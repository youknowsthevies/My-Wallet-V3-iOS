// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxSwift

class MockCoincore: CoincoreAPI {

    var allAccounts: Single<AccountGroup> = Observable<AccountGroup>.empty().asSingle()

    func initialize() -> Completable {
        .just(event: .completed)
    }

    func initializePublisher() -> AnyPublisher<Never, Never> {
        initialize().asPublisher().ignoreFailure()
    }

    func getTransactionTargets(sourceAccount: BlockchainAccount, action: AssetAction) -> Single<[SingleAccount]> {
        .just([])
    }

    var requestedCryptoAsset: CryptoAsset?
    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset? {
        requestedCryptoAsset
    }
}
