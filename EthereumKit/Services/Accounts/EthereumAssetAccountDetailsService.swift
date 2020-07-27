//
//  EthereumAssetAccountDetailsService.swift
//  EthereumKit
//
//  Created by Jack on 19/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import BigInt
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

    public convenience init(with bridge: EthereumWalletBridgeAPI) {
        self.init(with: bridge, client: resolve())
    }

    public init(with bridge: EthereumWalletBridgeAPI, client: APIClientAPI) {
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
