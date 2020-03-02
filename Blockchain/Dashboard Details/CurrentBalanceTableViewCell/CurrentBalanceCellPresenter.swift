//
//  CurrentBalanceCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import PlatformKit
import PlatformUIKit

final class CurrentBalanceCellPresenter {
    
    /// Returns the visibility of the custodial imageView
    var custodialVisibility: Driver<Visibility> {
        return imageViewVisibilityRelay.asDriver()
    }
    
    /// Returns the `Description`
    var description: Driver<String> {
        return descriptionRelay.asDriver()
    }
    
    let assetBalanceViewPresenter: AssetBalanceViewPresenter
    let currency: CryptoCurrency
    let balanceType: BalanceType
    
    // MARK: - Private Properties
    
    private let imageViewVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    
    init(balanceFetching: AssetBalanceFetching,
         currency: CryptoCurrency,
         balanceType: BalanceType,
         alignment: UIStackView.Alignment) {
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: alignment,
            interactor: AssetBalanceTypeViewInteractor(
                assetBalanceFetching:
                balanceFetching,
                balanceType: balanceType
            )
        )
        self.currency = currency
        self.balanceType = balanceType
        
        switch balanceType {
        case .nonCustodial:
            imageViewVisibilityRelay.accept(.hidden)
            descriptionRelay.accept("\(LocalizationConstants.wallet) \(LocalizationConstants.Swap.balance)")
        case .custodial:
            imageViewVisibilityRelay.accept(.visible)
            descriptionRelay.accept(LocalizationConstants.tradingWallet)
        }
    }
}
