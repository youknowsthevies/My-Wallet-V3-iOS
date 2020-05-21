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
    
    private typealias LocalizedString = LocalizationConstants.DashboardDetails.BalanceCell
    
    var iconImageViewContent: Driver<ImageViewContent> {
        iconImageViewContentRelay.asDriver()
    }
    
    var imageViewContent: Driver<ImageViewContent> {
        imageViewContentRelay.asDriver()
    }
    
    /// Returns the description of the balance
    var title: Driver<String> {
        titleRelay.asDriver()
    }
    
    /// Returns the description of the balance
    var description: Driver<String> {
        descriptionRelay.asDriver()
    }
        
    let assetBalanceViewPresenter: AssetBalanceViewPresenter
        
    // MARK: - Private Properties
    
    private let imageViewContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    private let iconImageViewContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    
    private let disposeBag = DisposeBag()
    
    init(balanceFetcher: AssetBalanceFetching,
         descriptionValue: () -> Observable<String>,
         currency: CryptoCurrency,
         balanceType: BalanceType,
         alignment: UIStackView.Alignment) {
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: alignment,
            interactor: AssetBalanceTypeViewInteractor(
                assetBalanceFetching: balanceFetcher,
                balanceType: balanceType
            )
        )
        
        imageViewContentRelay.accept(ImageViewContent(imageName: currency.logoImageName))
        switch balanceType {
        case .nonCustodial:
            iconImageViewContentRelay.accept(.empty)
            titleRelay.accept(currency.name)
        case .custodial(.trading):
            iconImageViewContentRelay.accept(ImageViewContent(imageName: "icon_custody_lock"))
            titleRelay.accept(LocalizedString.Title.trading)
        case .custodial(.savings):
            iconImageViewContentRelay.accept(.empty)
            titleRelay.accept(LocalizedString.Title.savings)
        }
        
        descriptionValue()
            .bind(to: descriptionRelay)
            .disposed(by: disposeBag)
    }
}
