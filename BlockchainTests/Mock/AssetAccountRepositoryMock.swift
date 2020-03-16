//
//  AssetAccountRepositoryMock.swift
//  BlockchainTests
//
//  Created by Jack on 03/07/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
@testable import Blockchain

class AssetAccountRepositoryMock: Blockchain.AssetAccountRepositoryAPI {
    var accounts: Single<[Blockchain.AssetAccount]> {
        return .just([])
    }

    var fetchETHHistoryIfNeeded: Single<Void> {
        .just(())
    }

    func accounts(for assetType: CryptoCurrency) -> Single<[Blockchain.AssetAccount]> {
        return .just([])
    }

    func accounts(for assetType: CryptoCurrency, fromCache: Bool) -> Single<[Blockchain.AssetAccount]> {
        return .just([])
    }

    func nameOfAccountContaining(address: String, currencyType: CryptoCurrency) -> Single<String> {
        return .just("")
    }

    func defaultAccount(for assetType: CryptoCurrency) -> Single<Blockchain.AssetAccount?> {
        return .just(nil)
    }

    func fetchAccounts() -> Single<[Blockchain.AssetAccount]> {
        return .just([])
    }
}
