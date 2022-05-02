// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import MoneyKit
import PlatformKit
import PlatformUIKit

struct ERC20ActivityDetailsViewModel: Equatable {

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
        fileprivate static let empty: Amounts = .init(fee: .empty, gasFor: nil)

        struct Value: Equatable {
            fileprivate static let empty: Value = .init(cryptoAmount: "", value: "")
            let cryptoAmount: String
            let value: String
        }

        let fee: Value
        let gasFor: Value?
    }

    let confirmation: Confirmation
    let dateCreated: String
    let to: String?
    let from: String
    let amounts: Amounts
    let fee: String
}
