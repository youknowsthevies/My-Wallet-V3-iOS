// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCoinDomain
import SwiftUI

public struct CoinViewState: Equatable {
    let assetDetails: AssetDetails
    var kycStatus: KYCStatus?
    var accounts: [Account]
    var hasPositiveBalanceForSelling: Bool?
    var interestRate: Double?

    var graph = GraphViewState()

    // Dynamic Actions

    var primaryAction: DoubleButtonAction? {
        if assetDetails.tradeable {
            return .buy
        } else {
            return .send
        }
    }

    var secondaryAction: DoubleButtonAction? {
        switch (assetDetails.tradeable, hasPositiveBalanceForSelling, kycStatus?.canSellCrypto) {
        case (true, true, true):
            return .sell
        default:
            return .receive
        }
    }

    public init(
        assetDetails: AssetDetails,
        kycStatus: KYCStatus? = nil,
        accounts: [Account] = []
    ) {
        self.assetDetails = assetDetails
        self.kycStatus = kycStatus
        self.accounts = accounts
    }
}
