//
//  ETHDependencies.swift
//  EthereumKit
//
//  Created by Paulo on 21/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol ETHDependencies {
    var activity: ActivityItemEventFetcherAPI { get }
    var activityDetails: AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> { get }
    var assetAccountRepository: EthereumAssetAccountRepository { get }
    var qrMetadataFactory: EthereumQRMetadataFactory { get }
    var repository: EthereumWalletAccountRepository { get }
    var transactionService: EthereumHistoricalTransactionService { get }
}
