//
//  CardsSettingsSectionPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit
import RxCocoa

final class CardsSettingsSectionPresenter {
    
    // MARK: - Types
    
    private typealias ViewModel = LinkedCardCellPresenter.CardDataViewModel
    
    // MARK: - Public Properties
    
    var presenters: Observable<[LinkedCardCellPresenter]> {
        dataRelay
            .asObservable()
            .map { $0.map { LinkedCardCellPresenter(acceptsUserInteraction: false, viewModel: $0) } }
    }
    
    // MARK: - Private Properties
    
    private let dataRelay = BehaviorRelay<[ViewModel]>(value: [])
    private let interactor: CardSettingsSectionInteractor
    private let disposeBag = DisposeBag()
    
    init(service: CardListServiceAPI, payments: SimpleBuyPaymentMethodsServiceAPI) {
        interactor = .init(service: service, payments: payments)
        interactor.state
            .compactMap { $0.value }
            .map { $0.map { .init(data: $0.data, max: $0.max) } }
            .bind(to: dataRelay)
            .disposed(by: disposeBag)
    }
}
