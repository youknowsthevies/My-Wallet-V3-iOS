//
//  EthereumAssetAccountDetailsService.swift
//  EthereumKit
//
//  Created by Jack on 19/03/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import BigInt

public class EthereumAssetAccountDetailsService: AssetAccountDetailsAPI {

    // MARK: - Properties

    private var balanceDetails: Single<BalanceDetailsResponse> {
        return bridge
            .address
            .flatMap(weak: self) { (self, address) -> Single<BalanceDetailsResponse> in
                self.client.balanceDetails(from: address.publicKey)
            }
    }

    // MARK: - Injected

    private let bridge: EthereumWalletBridgeAPI
    private let client: EthereumClientAPI

    // MARK: - Setup

    public convenience init(with bridge: EthereumWalletBridgeAPI) {
        self.init(with: bridge, client: APIClient())
    }

    public init(with bridge: EthereumWalletBridgeAPI, client: EthereumClientAPI) {
        self.bridge = bridge
        self.client = client
    }

    // TODO: IOS-3217 Method should use accountID parameter.
    /// Streams the account details
    public func accountDetails(for accountID: String) -> Single<EthereumAssetAccountDetails> {
        return Single
            .zip(bridge.account, balanceDetails)
            .map { accountAndDetails -> EthereumAssetAccountDetails in
                return EthereumAssetAccountDetails(
                    account: accountAndDetails.0,
                    balance: accountAndDetails.1.cryptoValue,
                    nonce: accountAndDetails.1.nonce
                )
            }
    }
}
