//
//  TransactionDescriptorViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 10/9/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxCocoa
import RxRelay

public struct TransactionDescriptorViewModel {
    public var transactionTypeBadgeImageViewModel: Driver<BadgeImageViewModel> {
        let viewModel = BadgeImageViewModel.template(
            with: "swap-icon",
            templateColor: .primaryButton,
            backgroundColor: .lightBlueBackground,
            accessibilityIdSuffix: ""
        )
        viewModel.marginOffsetRelay.accept(0)
        return Driver.just(viewModel)
    }
    
    public var fromAccountBadgeImageViewModel: Driver<BadgeImageViewModel> {
        fromAccountRelay
            .map { (imageName: $0.currencyType.logoImageName, isFiat: $0.currencyType.isFiatCurrency) }
            // This should not happen.
            .asDriver(onErrorJustReturn: (imageName: "", isFiat: false))
            .map { (imageName: String, isFiat: Bool) -> BadgeImageViewModel in
                let model = BadgeImageViewModel.default(
                    with: imageName,
                    cornerRadius: isFiat ? .value(8.0) : .round,
                    accessibilityIdSuffix: ""
                )
                model.marginOffsetRelay.accept(0)
                return model
            }
    }
    
    public var toAccountBadgeImageViewModel: Driver<BadgeImageViewModel> {
        toAccountRelay
            .map { (imageName: $0.currencyType.logoImageName, isFiat: $0.currencyType.isFiatCurrency) }
            // This should not happen.
            .asDriver(onErrorJustReturn: (imageName: "", isFiat: false))
            .map { (imageName: String, isFiat: Bool) -> BadgeImageViewModel in
                let model = BadgeImageViewModel.default(
                    with: imageName,
                    cornerRadius: isFiat ? .value(8.0) : .round,
                    accessibilityIdSuffix: ""
                )
                model.marginOffsetRelay.accept(0)
                return model
            }
    }
    
    /// The `SingleAccount` that the transaction is originating from
    public let fromAccountRelay = PublishRelay<SingleAccount>()
    
    /// The `SingleAccount` that is the destination for the transaction
    public let toAccountRelay = PublishRelay<SingleAccount>()
}
