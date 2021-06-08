// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift

public protocol EthereumAccountDetailsServiceAPI {

    /// Streams the default account details.
    func accountDetails() -> Single<EthereumAssetAccountDetails>
}

class EthereumAccountDetailsService: EthereumAccountDetailsServiceAPI {

    // MARK: - Properties

    private var balanceDetails: Single<BalanceDetailsResponse> {
        bridge
            .address
            .flatMap(weak: self) { (self, address) -> Single<BalanceDetailsResponse> in
                self.client.balanceDetails(from: address.publicKey)
            }
    }

    // MARK: - Injected

    private let bridge: EthereumWalletBridgeAPI
    private let client: BalanceClientAPI

    // MARK: - Setup

    init(with bridge: EthereumWalletBridgeAPI = resolve(), client: BalanceClientAPI = resolve()) {
        self.bridge = bridge
        self.client = client
    }

    func accountDetails() -> Single<EthereumAssetAccountDetails> {
        Single
            .zip(bridge.account, balanceDetails)
            .map { accountAndDetails -> EthereumAssetAccountDetails in
                EthereumAssetAccountDetails(
                    account: accountAndDetails.0,
                    balance: accountAndDetails.1.cryptoValue,
                    nonce: accountAndDetails.1.nonce
                )
            }
    }
}
