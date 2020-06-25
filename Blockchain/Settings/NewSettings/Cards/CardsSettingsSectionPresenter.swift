//
//  CardsSettingsSectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellUIKit
import PlatformKit
import RxCocoa
import RxSwift

final class CardsSettingsSectionPresenter {
    
    // MARK: - Properties
    
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

    private let interactor: CardSettingsSectionInteractor
    
    init(interactor: CardSettingsSectionInteractor) {
        self.interactor = interactor
    }
}
