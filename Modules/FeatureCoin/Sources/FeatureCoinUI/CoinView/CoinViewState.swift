// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BlockchainComponentLibrary
import ComposableArchitecture
import FeatureCoinDomain
import MoneyKit
import SwiftUI

public enum CoinViewError: Error, Equatable {
    case failedToLoad
}

public struct CoinViewState: Equatable {

    public let currency: CryptoCurrency
    public var accounts: [Account.Snapshot]
    public var error: CoinViewError?
    public var information: AssetInformation?
    public var interestRate: Double?
    public var kycStatus: KYCStatus?
    public var isFavorite: Bool?

    @BindableState public var account: Account.Snapshot?
    @BindableState public var explainer: Account.Snapshot?

    public var graph = GraphViewState()

    var actions: [ButtonAction] {
        if !currency.isTradable || accounts.isEmpty {
            return accounts.hasPositiveBalanceForSelling ? [.send] : []
        }
        let (buy, sell, send, receive) = (
            action(.buy, whenAccountCan: .buy),
            action(.sell, whenAccountCan: .sell),
            action(.send, whenAccountCan: .send),
            action(.receive, whenAccountCan: .receive)
        )
        if kycStatus?.canSellCrypto == false || !accounts.hasPositiveBalanceForSelling {
            return [receive, buy].compactMap { $0 }
        }
        let actions = [sell, buy].compactMap { $0 }
        if actions.isEmpty {
            return [send, receive].compactMap { $0 }
        } else {
            return actions
        }
    }

    private func action(_ action: ButtonAction, whenAccountCan accountAction: Account.Action) -> ButtonAction? {
        accounts.contains(where: { account in account.actions.contains(accountAction) }) ? action : nil
    }

    public init(
        currency: CryptoCurrency,
        kycStatus: KYCStatus? = nil,
        accounts: [Account.Snapshot] = [],
        error: CoinViewError? = nil
    ) {
        self.currency = currency
        self.kycStatus = kycStatus
        self.accounts = accounts
        self.error = error
    }
}

extension CryptoCurrency {

    var isTradable: Bool {
        supports(product: .custodialWalletBalance) || supports(product: .privateKey)
    }
}
