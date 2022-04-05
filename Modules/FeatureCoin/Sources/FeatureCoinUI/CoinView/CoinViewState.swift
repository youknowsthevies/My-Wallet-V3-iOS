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
    public var isFavorite: Bool?

    @BindableState public var account: Account.Snapshot?
    @BindableState public var explainer: Account.Snapshot?

    public var graph = GraphViewState()

    var actions: [ButtonAction] {
        guard asset.isTradable else {
            return accounts.hasPositiveBalanceForSelling ? [.send] : []
        }
        let (buy, sell, receive) = (
            action(.buy, whenAccountCan: .buy),
            action(.sell, whenAccountCan: .sell),
            action(.receive, whenAccountCan: .receive)
        )
        guard accounts.hasPositiveBalanceForSelling else {
            return [receive, buy].compacted().array
        }
        guard kycStatus?.canSellCrypto == true else {
            return [receive, buy].compacted().array
        }
        return [sell, buy].compacted().array
    }

    private func action(_ action: ButtonAction, whenAccountCan accountAction: Account.Action) -> ButtonAction? {
        accounts.contains(where: { account in account.actions.contains(accountAction) }) ? action : nil
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
