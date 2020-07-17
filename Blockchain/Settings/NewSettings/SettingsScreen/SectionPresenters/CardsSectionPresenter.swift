//
//  CardsSectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 7/14/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import PlatformKit
import RxSwift

final class CardsSectionPresenter: SettingsSectionPresenting {
    let sectionType: SettingsSectionType = .cards
    
    var state: Observable<SettingsSectionLoadingState> {
        interactor
        .state
            .map(weak: self) { (self, interactorState) -> SettingsSectionLoadingState in
                switch interactorState {
                case .invalid:
                    /// Do not show the `Linked Cards` section
                    return .loaded(next: .empty)
                case .calculating:
                    /// Show a loading cell should cards be enabled but we are
                    /// still waiting on CardData.
                    let cells: [SettingsCellViewModel] = [.init(cellType: .cards(.skeleton(0)))]
                    return .loaded(next: .some(.init(sectionType: .cards, items: cells)))
                case .value(let cardData):
                    /// Show the card cells in addition to a
                    /// `Add Card` cell.
                    let presenters = cardData.presenters
                    let addCardCellViewModel: SettingsCellViewModel = .init(
                        cellType: .cards(.addCard(self.addCardCellPresenter))
                    )
                    let cells = presenters.viewModels + [addCardCellViewModel]
                    let viewModel: SettingsSectionViewModel = .init(
                        sectionType: self.sectionType,
                        items: cells
                    )
                    
                    return .loaded(next: .some(viewModel))
                }
            }
    }
    
    // MARK: - Private Properties

    private let addCardCellPresenter: AddCardCellPresenter
    private let featureConfiguration: AppFeatureConfiguration
    private let interactor: CardSettingsSectionInteractor
    
    init(interactor: CardSettingsSectionInteractor,
         paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI,
         tierLimitsProviding: TierLimitsProviding,
         featureConfiguration: AppFeatureConfiguration,
         featureFetcher: FeatureFetching) {
        self.interactor = interactor
        self.featureConfiguration = featureConfiguration
        self.addCardCellPresenter = .init(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding,
            featureFetcher: featureFetcher
        )
    }
}

fileprivate extension Array where Element == CardData {
    var presenters: [LinkedCardCellPresenter] {
        map { data in
            .init(acceptsUserInteraction: false, cardData: data)
        }
    }
}

fileprivate extension Array where Element == LinkedCardCellPresenter {
    var viewModels: [SettingsCellViewModel] {
        map { presenter in
            .init(cellType: .cards(.linkedCard(presenter)))
        }
    }
}
