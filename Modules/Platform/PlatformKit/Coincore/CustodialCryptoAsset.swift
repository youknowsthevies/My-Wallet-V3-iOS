// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

final class CustodialCryptoAsset: CryptoAsset {

    var defaultAccount: Single<SingleAccount> {
        .error(CryptoAssetError.noDefaultAccount)
    }

    let asset: CryptoCurrency
    let kycTiersService: KYCTiersServiceAPI

    init(asset: CryptoCurrency,
         kycTiersService: KYCTiersServiceAPI = resolve()) {
        self.asset = asset
        self.kycTiersService = kycTiersService
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
        switch filter {
        case .all, .custodial:
            return .just(CryptoAccountCustodialGroup(
                asset: asset,
                accounts: [CryptoTradingAccount(asset: asset)]
            ))
        case .interest:
            return .just(CryptoAccountCustodialGroup(asset: asset, accounts: []))
        case .nonCustodial:
            return .just(CryptoAccountNonCustodialGroup(asset: asset, accounts: []))
        }
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        .just(nil)
    }
}
