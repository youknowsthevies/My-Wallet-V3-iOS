// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift

public class EthereumAssetAccountDetailsService: AssetAccountDetailsAPI {

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
    private let client: APIClientAPI

    // MARK: - Setup

    init(with bridge: EthereumWalletBridgeAPI = resolve(), client: APIClientAPI = resolve()) {
        self.bridge = bridge
        self.client = client
    }

    // TODO: IOS-3217 Method should use accountID parameter.
    /// Streams the account details
    public func accountDetails(for accountID: String) -> Single<EthereumAssetAccountDetails> {
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
