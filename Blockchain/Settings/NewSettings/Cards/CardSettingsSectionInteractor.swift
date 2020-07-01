//
//  CardSettingsSectionInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import RxRelay
import RxSwift

final class CardSettingsSectionInteractor {
    
    typealias State = LoadingState<[CardData]>
    
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    private let stateRelay = BehaviorRelay<State>(value: .loading)
    private let disposeBag = DisposeBag()
    private let service: BuySellKit.PaymentMethodTypesServiceAPI
    
    private var cards: Observable<[CardData]> {
        service.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchErrorJustReturn([])
    }

    // MARK: - Setup
    
    init(service: BuySellKit.PaymentMethodTypesServiceAPI) {
        self.service = service
        cards
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
