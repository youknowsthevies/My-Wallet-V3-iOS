//
//  AddCardLabelContentPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import BuySellKit
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class AddCardLabelContentPresenter: LabelContentPresenting {
    
    typealias PresentationState = LabelContent.State.Presentation
    
    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    let interactor: LabelContentInteracting
    private let disposeBag = DisposeBag()
    
    init(paymentMethodTypesService: BuySellKit.PaymentMethodTypesServiceAPI,
         tierLimitsProviding: TierLimitsProviding,
         featureFeatcher: FeatureFetching) {
        
        let interactor = AddCardLabelContentInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding,
            featureFetcher: featureFeatcher
        )
        self.interactor = interactor

        Observable
            .combineLatest(
                interactor.state,
                interactor.descriptorObservable
            )
            .map { PresentationState(with: $0.0, descriptors: $0.1) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
