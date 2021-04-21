//
//  WalletViewViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 2/22/21.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

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
        let accountType = account.accountType
        identifier = account.id
        badgeImageViewModel = .default(
            with: currency.logoImageName,
            cornerRadius: .round,
            accessibilityIdSuffix: ""
        )
        
        switch (accountType, currency) {
        case (.nonCustodial, .fiat),
             (.custodial, .fiat):
            accountTypeBadge = .empty
        case (.custodial(.exchange), .crypto):
            accountTypeBadge = .template(
                with: "ic-exchange-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (.nonCustodial, .crypto):
            accountTypeBadge = .template(
                with: "ic-private-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (.custodial(.trading), .crypto):
            accountTypeBadge = .template(
                with: "ic-trading-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        case (.custodial(.savings), .crypto):
            accountTypeBadge = .template(
                with: "ic-interest-account",
                templateColor: currency.brandColor,
                backgroundColor: .white,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
        }
        
        badgeImageViewModel.marginOffsetRelay.accept(0.0)
        accountTypeBadge.marginOffsetRelay.accept(1.0)
        
        nameLabelContent = .init(
            text: account.label,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .left,
            accessibility: .init(id: .value("\(descriptor.accessibilityPrefix).wallet.name"))
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
                            accessibility: .init(id: .value("\(descriptor.accessibilityPrefix).wallet.balance"))
                        )
                    }
                    .asDriver(onErrorJustReturn: .empty)
    }
}
