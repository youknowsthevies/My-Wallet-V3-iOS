//
//  BiometryLabelContentPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/7/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

class BiometryLabelContentPresenter: LabelContentPresenting {
    
    // MARK: - Types
    
    typealias PresentationState = LabelContent.State.Presentation
    
    // MARK: - Properties
    
    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    let interactor: LabelContentInteracting
    private let disposeBag = DisposeBag()
    
    init(provider: BiometryProviding,
         descriptors: LabelContent.Value.Presentation.Content.Descriptors) {
        interactor = BiometryLabelContentInteractor(biometryProviding: provider)
        interactor.state
            .map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
