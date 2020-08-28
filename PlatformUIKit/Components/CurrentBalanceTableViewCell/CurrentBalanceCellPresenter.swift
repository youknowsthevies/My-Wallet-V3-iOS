//
//  CurrentBalanceCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Localization
import PlatformKit
import RxCocoa
import RxDataSources
import RxSwift

public final class CurrentBalanceCellPresenter: CurrentBalanceCellPresenting {
    
    public typealias DescriptionValue = () -> Observable<String>
    
    private typealias LocalizedString = LocalizationConstants.DashboardDetails.BalanceCell
    
    public var iconImageViewContent: Driver<ImageViewContent> {
        iconImageViewContentRelay.asDriver()
    }
    
    public var badgeImageViewModel: Driver<BadgeImageViewModel> {
        badgeRelay.asDriver()
    }
    
    /// Returns the description of the balance
    public var title: Driver<String> {
        titleRelay.asDriver()
    }
    
    /// Returns the description of the balance
    public var description: Driver<String> {
        _ = setup
        return descriptionRelay.asDriver()
    }
    
    public var separatorVisibility: Driver<Visibility> {
        separatorVisibilityRelay.asDriver()
    }
    
    var identifier: String {
        "\(balanceType.description).\(currency.name)"
    }
    
    public let titleAccessibilitySuffix: String
    public let descriptionAccessibilitySuffix: String
        
    public let currency: CurrencyType
    public var balanceType: BalanceType {
        interactor.balanceType
    }
    public let assetBalanceViewPresenter: AssetBalanceViewPresenter
        
    // MARK: - Private Properties
    
    private lazy var setup: Void = {
        descriptionValue()
            .catchErrorJustReturn("")
            .bindAndCatch(to: descriptionRelay)
            .disposed(by: disposeBag)
    }()
    
    private let badgeRelay = BehaviorRelay<BadgeImageViewModel>(value: .empty)
    private let separatorVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let iconImageViewContentRelay = BehaviorRelay<ImageViewContent>(value: .empty)
    private let titleRelay = BehaviorRelay<String>(value: "")
    private let descriptionRelay = BehaviorRelay<String>(value: "")
    private let interactor: CurrentBalanceCellInteracting
    private let descriptionValue: DescriptionValue
    
    private let disposeBag = DisposeBag()
    
    public init(interactor: CurrentBalanceCellInteracting,
                descriptionValue: @escaping DescriptionValue,
                currency: CurrencyType,
                separatorVisibility: Visibility = .hidden,
                titleAccessibilitySuffix: String,
                descriptionAccessibilitySuffix: String,
                descriptors: DashboardAsset.Value.Presentation.AssetBalance.Descriptors) {
        self.titleAccessibilitySuffix = titleAccessibilitySuffix
        self.descriptionAccessibilitySuffix = descriptionAccessibilitySuffix
        separatorVisibilityRelay.accept(separatorVisibility)
        self.interactor = interactor
        self.assetBalanceViewPresenter = AssetBalanceViewPresenter(
            alignment: .trailing,
            interactor: interactor.assetBalanceViewInteractor,
            descriptors: descriptors
        )
        self.currency = currency
        self.descriptionValue = descriptionValue

        switch currency {
        case .fiat(let fiatCurrency):
            let badgeImageViewModel: BadgeImageViewModel = .primary(
                with: fiatCurrency.logoImageName,
                contentColor: .white,
                backgroundColor: .fiat,
                accessibilityIdSuffix: ""
            )
            badgeImageViewModel.marginOffsetRelay.accept(0)
            badgeRelay.accept(badgeImageViewModel)
        case .crypto(let cryptoCurrency):
            let badgeImageViewModel: BadgeImageViewModel = .default(
                with: cryptoCurrency.logoImageName,
                cornerRadius: .round,
                accessibilityIdSuffix: ""
            )
            badgeImageViewModel.marginOffsetRelay.accept(0)
            badgeRelay.accept(badgeImageViewModel)
        }
        
        switch (interactor.balanceType, currency) {
        case (.nonCustodial, _):
            titleRelay.accept(currency.name)
        case (.custodial(.trading), .crypto):
            iconImageViewContentRelay.accept(ImageViewContent(imageName: "icon_custody_lock", bundle: Bundle.platformUIKit))
            titleRelay.accept(LocalizedString.Title.trading)
        case (.custodial(.savings), .crypto):
            iconImageViewContentRelay.accept(.empty)
            titleRelay.accept(LocalizedString.Title.savings)
        case (.custodial, .fiat(let currency)):
            titleRelay.accept(currency.name)
        }
    }
}
