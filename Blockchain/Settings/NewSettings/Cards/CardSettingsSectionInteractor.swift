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
import ToolKit

final class CardSettingsSectionInteractor {
    
    typealias State = ValueCalculationState<[CardData]>
    
    enum CardSettingsSectionError: Error {
        case notSupported
    }
    
    var state: Observable<State> {
        _ = setup
        return stateRelay
            .asObservable()
    }
    
    private lazy var setup: Void = {
        featureFetching
            .fetchBool(for: .simpleBuyCardsEnabled)
            .asObservable()
            .flatMap(weak: self) { (self, enabled) -> Observable<State> in
                guard enabled else { return .just(.invalid(.empty)) }
                return self.cards.map { values -> State in
                    return .value(values)
                }
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()
    
    private let stateRelay = BehaviorRelay<State>(value: .invalid(.empty))
    private let featureFetching: FeatureFetching
    private let service: BuySellKit.PaymentMethodTypesServiceAPI
    private let disposeBag = DisposeBag()
    
    private var cards: Observable<[CardData]> {
        service.cards
            .map { $0.filter { $0.state == .active || $0.state == .expired } }
            .catchErrorJustReturn([])
    }

    // MARK: - Setup
    
    init(featureFetching: FeatureFetching = AppFeatureConfigurator.shared,
         service: BuySellKit.PaymentMethodTypesServiceAPI) {
        self.featureFetching = featureFetching
        self.service = service
    }
}
