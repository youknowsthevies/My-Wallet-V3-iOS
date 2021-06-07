// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import RxSwift

class EthereumAccountDetailsServiceAPIMock: EthereumAccountDetailsServiceAPI {
    var underlyingAccountDetails: Single<EthereumAssetAccountDetails> = .just(.defaultMock)
    func accountDetails() -> Single<EthereumAssetAccountDetails> {
        underlyingAccountDetails
    }
}
