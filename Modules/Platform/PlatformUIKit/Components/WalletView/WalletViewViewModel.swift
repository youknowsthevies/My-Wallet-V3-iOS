// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift

final class WalletViewViewModel {

    struct Descriptors {
        let accessibilityPrefix: String
    }

    let identifier: String
    let accountTypeBadge: BadgeImageViewModel
    let badgeImageViewModel: BadgeImageViewModel
    let nameLabelContent: LabelContent
    let balanceLabelContent: Driver<LabelContent>

    init(account: SingleAccount, descriptor: Descriptors) {
        let currency = account.currencyType
        identifier = account.id
        badgeImageViewModel = .default(
            with: currency.logoImageName,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        )

        switch (account, currency) {
        case (is NonCustodialAccount, .fiat),
             (is TradingAccount, .fiat):
            accountTypeBadge = .empty
        case (is ExchangeAccount, .crypto):
            accountTypeBadge = .template(
                with: "ic-exchange-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (is NonCustodialAccount, .crypto):
            accountTypeBadge = .template(
                with: "ic-private-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (is TradingAccount, .crypto):
            accountTypeBadge = .template(
                with: "ic-trading-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (is CryptoInterestAccount, .crypto):
            accountTypeBadge = .template(
                with: "ic-interest-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        default:
            fatalError("Unhandled account type: \(String(describing: account))")
        }

        badgeImageViewModel.marginOffsetRelay.accept(0.0)
        accountTypeBadge.marginOffsetRelay.accept(1.0)

        nameLabelContent = .init(
            text: account.label,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .id("\(descriptor.accessibilityPrefix).wallet.name")
        )
        guard !(account is CryptoExchangeAccount) else {
            /// Exchange accounts don't have a balance
            /// that we can readily access at this time.
            balanceLabelContent = .empty()
            return
        }

        balanceLabelContent = account
            .balance
            .map(\.displayString)
            .map { value in
                .init(
                    text: value,
                    font: .main(.medium, 14.0),
                    color: .descriptionText,
                    alignment: .left,
                    accessibility: .id("\(descriptor.accessibilityPrefix).wallet.balance")
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }
}
