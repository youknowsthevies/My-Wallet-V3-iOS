// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import FeatureCoinDomain
import SwiftUI

public struct CoinViewState: Equatable {
    let assetDetails: AssetDetails
    var kycStatus: KYCStatus?
    var priceDetails: PriceDetails?
    var balanceDetails: BalanceDetails?
    var accounts: [Account]
    var graph = CoinViewGraphState()

    // Dynamic Actions

    var primaryAction: DoubleButtonAction? {
        if assetDetails.tradeable {
            return .buy
        } else {
            return .send
        }
    }

    var secondaryAction: DoubleButtonAction? {
        switch (assetDetails.tradeable, balanceDetails?.positiveBalance, kycStatus?.canPurchaseCrypto) {
        case (true, true, true):
            return .sell
        default:
            return .receive
        }
    }

    public init(
        assetDetails: AssetDetails,
        kycStatus: KYCStatus? = nil,
        priceDetails: PriceDetails? = nil,
        balanceDetails: BalanceDetails? = nil,
        accounts: [Account] = []
    ) {
        self.assetDetails = assetDetails
        self.kycStatus = kycStatus
        self.priceDetails = priceDetails
        self.balanceDetails = balanceDetails
        self.accounts = accounts
    }
}
