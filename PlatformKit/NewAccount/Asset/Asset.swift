//
//  Asset.swift
//  PlatformKit
//
//  Created by Paulo on 29/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public enum AssetFilter {
    case all
    case nonCustodial
    case custodial
    case interest
}

public enum AssetAction {
    case viewActivity
    case deposit
    case sell
    case send
    case receive
    case swap
    case withdraw
}

public typealias AvailableActions = Set<AssetAction>

public protocol Asset {

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup>
}

public protocol CryptoAsset: Asset {
    var asset: CryptoCurrency { get }
    var defaultAccount: Single<SingleAccount> { get }
}

public enum CryptoAssetError: Error {
    case noDefaultAccount
}
