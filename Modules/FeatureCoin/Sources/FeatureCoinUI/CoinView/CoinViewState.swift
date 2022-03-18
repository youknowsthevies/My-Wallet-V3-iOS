// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCoinDomain
import SwiftUI

public enum CoinViewError: Error, Equatable {
    case failedToLoad
}

public struct CoinViewState: Equatable {

    public let asset: AssetDetails
    public var kycStatus: KYCStatus?
    public var accounts: [Account.Snapshot]
    public var interestRate: Double?
    public var error: CoinViewError?

    @BindableState public var account: Account.Snapshot?
    @BindableState public var explainer: Account.Snapshot?

    public var graph = GraphViewState()

    var primaryAction: ButtonAction? {
        if asset.isTradable { return .buy }
        if accounts.hasPositiveBalanceForSelling { return .send }
        return nil
    }

    var secondaryAction: ButtonAction? {
        guard asset.isTradable, accounts.hasPositiveBalanceForSelling else { return .receive }
        guard let kyc = kycStatus, kyc.canSellCrypto else { return .receive }
        return .sell
    }

    public init(
        asset: AssetDetails,
        kycStatus: KYCStatus? = nil,
        accounts: [Account.Snapshot] = [],
        error: CoinViewError? = nil
    ) {
        self.asset = asset
        self.kycStatus = kycStatus
        self.accounts = accounts
        self.error = error
    }
}
