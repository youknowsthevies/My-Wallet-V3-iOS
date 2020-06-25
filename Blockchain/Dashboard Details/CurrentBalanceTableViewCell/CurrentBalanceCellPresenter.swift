//
//  CurrentBalanceCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

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
    
    var separatorVisibility: Driver<Visibility> {
        separatorVisibilityRelay.asDriver()
    }
    
    let titleAccessibilitySuffix: String
    let descriptionAccessibilitySuffix: String
        
    let currency: CryptoCurrency
    var balanceType: BalanceType {
        interactor.balanceType
    }
    let assetBalanceViewPresenter: AssetBalanceViewPresenter
        
    // MARK: - Private Properties
    
    private let separatorVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let imageViewContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    private let iconImageViewContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let interactor: CurrentBalanceCellInteractor
    
    private let disposeBag = DisposeBag()
    
    init(interactor: CurrentBalanceCellInteractor,
         descriptionValue: () -> Observable<String>,
         currency: CryptoCurrency,
         alignment: UIStackView.Alignment,
         separatorVisibility: Visibility = .hidden,
         titleAccessibilitySuffix: String,
         descriptionAccessibilitySuffix: String,
         descriptors: DashboardAsset.Value.Presentation.AssetBalance.Descriptors) {
        self.titleAccessibilitySuffix = titleAccessibilitySuffix
        self.descriptionAccessibilitySuffix = descriptionAccessibilitySuffix
        separatorVisibilityRelay.accept(separatorVisibility)
        self.interactor = interactor
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: alignment,
            interactor: interactor.assetBalanceViewInteractor,
            descriptors: descriptors
        )
        self.currency = currency
        imageViewContentRelay.accept(ImageViewContent(imageName: currency.logoImageName))
        switch interactor.balanceType {
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
