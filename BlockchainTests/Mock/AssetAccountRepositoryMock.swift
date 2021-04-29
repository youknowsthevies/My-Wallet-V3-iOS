// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import PlatformKit
import RxSwift

class AssetAccountRepositoryMock: Blockchain.AssetAccountRepositoryAPI {
    typealias Error = AssetAccountRepository.AssetAccountRepositoryError
    
    var accounts: Single<[Blockchain.AssetAccount]> {
        .just([])
    }

    func accounts(for assetType: CryptoCurrency) -> Single<[Blockchain.AssetAccount]> {
        .just([])
    }

    func accounts(for assetType: CryptoCurrency, fromCache: Bool) -> Single<[Blockchain.AssetAccount]> {
        .just([])
    }

    func nameOfAccountContaining(address: String, currencyType: CryptoCurrency) -> Single<String> {
        .just("")
    }

    func defaultAccount(for assetType: CryptoCurrency) -> Single<Blockchain.AssetAccount> {
        Single.error(Error.noDefaultAccount)
    }

    func fetchAccounts() -> Single<[Blockchain.AssetAccount]> {
        .just([])
    }
}
