// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ERC20Kit
import PlatformKit
import RxSwift

class ERC20AssetAccountRepositoryMock: PlatformKit.AssetAccountRepositoryAPI {

    typealias Details = ERC20AssetAccountDetails

    var assetAccountDetails: Single<ERC20AssetAccountDetails> = Single.error(NSError())

    func currentAssetAccountDetails(fromCache: Bool) -> Single<ERC20AssetAccountDetails> {
        .error(NSError())
    }
}

class ERC20AssetAccountDetailsAPIMock: AssetAccountDetailsAPI {
    typealias AccountDetails = ERC20AssetAccountDetails

    var underlyingAccountDetails: Single<AccountDetails> = .error(NSError())
    func accountDetails(for accountID: String) -> Single<AccountDetails> {
        underlyingAccountDetails
    }
}
