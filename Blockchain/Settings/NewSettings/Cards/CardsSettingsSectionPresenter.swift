//
//  CardsSettingsSectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import BuySellUIKit
import PlatformKit
import RxCocoa
import RxSwift

final class CardsSettingsSectionPresenter {
    
    typealias Cell = SettingsCellViewModel
    typealias CellType = SettingsSectionType.CellType.CardsCellType
    
    // MARK: - Properties
    
    var cells: Observable<[Cell]> {
        interactor
        .state
            .map { state -> [Cell] in
                switch state {
                case .invalid:
                    return []
                case .calculating:
                    let cellTypes: [CellType] = [.skeleton(0)]
                    return cellTypes.map { SettingsCellViewModel(cellType: .cards($0)) }
                case .value(let data):
                    let presenters: [LinkedCardCellPresenter] = data.map { .init(acceptsUserInteraction: false, cardData: $0) }
                    let cellTypes: [CellType] = presenters.map { .linkedCard($0) }
                    return cellTypes.map { SettingsCellViewModel(cellType: .cards($0)) }
                }
        }
    }
    
    var presenters: Observable<[LinkedCardCellPresenter]> {
        interactor.state
            .compactMap { $0.value }
            .map {
                $0.map {
                    LinkedCardCellPresenter(acceptsUserInteraction: false, cardData: $0)
                }
            }
    }
    
    // MARK: - Private Properties

    private let addCardCellPresenter: AddCardCellPresenter
    private let interactor: CardSettingsSectionInteractor
    
    init(interactor: CardSettingsSectionInteractor,
         paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI,
         tierLimitsProviding: TierLimitsProviding,
         featureFetcher: FeatureFetching) {
        self.interactor = interactor
        self.addCardCellPresenter = .init(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding,
            featureFetcher: featureFetcher
        )
    }
}
