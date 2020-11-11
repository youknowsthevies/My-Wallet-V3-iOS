//
//  CardSettingsSectionInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

final class CardSettingsSectionInteractor {
    
    typealias State = ValueCalculationState<[CardData]>
    
    var state: Observable<State> {
        _ = setup
        return stateRelay
            .asObservable()
    }
    
    let addPaymentMethodInteractor: AddPaymentMethodInteractor
    
    private lazy var setup: Void = {
        featureFetcher
            .fetchBool(for: .simpleBuyCardsEnabled)
            .asObservable()
            .flatMap(weak: self) { (self, enabled) -> Observable<State> in
                guard enabled else { return .just(.invalid(.empty)) }
                return self.cardsState
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
        
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let disposeBag = DisposeBag()

    private var cardsState: Observable<State> {
        cards.map { values -> State in
            .value(values)
        }
    }

    private var cards: Observable<[CardData]> {
        paymentMethodTypesService.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchErrorJustReturn([])
    }

    // MARK: - Injected
    
    private let featureFetcher: FeatureFetching
    private let paymentMethodTypesService: PaymentMethodTypesServiceAPI
    private let tierLimitsProvider: TierLimitsProviding
    
    // MARK: - Setup
    
    init(featureFetcher: FeatureFetching = resolve(),
         paymentMethodTypesService: PaymentMethodTypesServiceAPI,
         tierLimitsProvider: TierLimitsProviding) {
        self.featureFetcher = featureFetcher
        self.paymentMethodTypesService = paymentMethodTypesService
        self.tierLimitsProvider = tierLimitsProvider
        
        addPaymentMethodInteractor = AddPaymentMethodInteractor(
            paymentMethod: .card,
            addNewInteractor: AddCardInteractor(
                paymentMethodTypesService: paymentMethodTypesService
            ),
            tiersLimitsProvider: tierLimitsProvider,
            featureFetcher: featureFetcher
        )
    }
}
