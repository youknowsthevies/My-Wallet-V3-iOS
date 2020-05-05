//
//  AddCardLabelContentPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class AddCardLabelContentPresenter: LabelContentPresenting {
    
    typealias PresentationState = LabelContent.State.Presentation
    
    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let interactor: AddCardLabelContentInteractor
    private let disposeBag = DisposeBag()
    
    init(paymentMethodTypesService: SimpleBuyPaymentMethodTypesService, tierLimitsProviding: TierLimitsProviding) {
        interactor = AddCardLabelContentInteractor(
            paymentMethodTypesService: paymentMethodTypesService,
            tierLimitsProviding: tierLimitsProviding
        )
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
