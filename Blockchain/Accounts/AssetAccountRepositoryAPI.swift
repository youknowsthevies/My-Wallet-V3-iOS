//
//  AssetAccountRepositoryAPI.swift
//  Blockchain
//
//  Created by Paulo on 20/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

protocol AssetAccountRepositoryAPI: AnyObject {
    var accounts: Single<[AssetAccount]> { get }
    var fetchETHHistoryIfNeeded: Single<Void> { get }
    func accounts(for assetType: CryptoCurrency) -> Single<[AssetAccount]>
    func accounts(for assetType: CryptoCurrency, fromCache: Bool) -> Single<[AssetAccount]>
    func nameOfAccountContaining(address: String, currencyType: CryptoCurrency) -> Single<String>
    func defaultAccount(for assetType: CryptoCurrency) -> Single<AssetAccount?>
    func fetchAccounts() -> Single<[AssetAccount]>
}
