//
//  CardSettingsSectionInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

final class CardSettingsSectionInteractor {
    
    typealias State = LoadingState<[InteractionModel]>
    
    struct InteractionModel {
        let data: CardData
        var max: FiatValue
    }
    
    var state: Observable<State> {
        stateRelay.asObservable()
    }
    
    private let stateRelay = BehaviorRelay<State>(value: .loading)
    private let disposeBag = DisposeBag()
    private let service: CardListServiceAPI
    private let payments: SimpleBuyPaymentMethodsServiceAPI
    private var cards: Observable<[CardData]> {
        service.cards.catchErrorJustReturn([])
    }
    private var max: Observable<FiatValue> {
        payments.paymentMethods
            .map { $0.filter { $0.type.isCard } }
            .compactMap { $0.first }
            .map { $0.max }
            .catchErrorJustReturn(.zero(currency: .USD))
    }
    
    // MARK: - Setup
    
    init(service: CardListServiceAPI, payments: SimpleBuyPaymentMethodsServiceAPI) {
        self.service = service
        self.payments = payments
        setup()
    }
    
    private func setup() {
        Observable.combineLatest(cards, max)
            .map { (data, max) -> [InteractionModel] in
                data.map { .init(data: $0, max: max) }
            }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
