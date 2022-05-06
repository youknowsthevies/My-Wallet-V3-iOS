// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

struct EthereumActivityDetailsViewModel: Equatable {

    typealias LocalizedString = LocalizationConstants.Activity.Details

    struct Confirmation: Equatable {
        fileprivate static let empty = Confirmation(
            needConfirmation: false,
            title: "",
            factor: 1,
            statusBadge: EthereumTransactionState.confirmed.statusBadge
        )
        let needConfirmation: Bool
        let title: String
        let factor: Float
        let statusBadge: BadgeAsset.Value.Interaction.BadgeItem
    }

    struct Amounts: Equatable {
        fileprivate static let empty: Amounts = .init(fee: .empty, trade: .empty, gasFor: nil, isGas: false)

        struct Value: Equatable {
            fileprivate static let empty: Value = .init(cryptoAmount: "", value: "")
            let cryptoAmount: String
            let value: String
        }

        let fee: Value
        let trade: Value
        let gasFor: Value?
        let isGas: Bool
    }

    let confirmation: Confirmation
    let dateCreated: String
    let to: String
    let from: String
    let amounts: Amounts
    let fee: String
    let note: String
}

extension EthereumTransactionState {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    var statusBadge: BadgeAsset.Value.Interaction.BadgeItem {
        switch self {
        case .confirmed:
            return .init(type: .verified, description: LocalizedString.completed)
        case .pending:
            return .init(type: .default(accessibilitySuffix: "Pending"), description: LocalizedString.pending)
        case .replaced:
            return .init(type: .verified, description: LocalizedString.replaced)
        }
    }
}
