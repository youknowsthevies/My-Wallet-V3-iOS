//
//  PasteboardLabelContentPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class PasteboardLabelContentPresenter: LabelContentPresenting {
    
    typealias PresentationState = LabelContentAsset.State.LabelItem.Presentation
    typealias PresentationDescriptors = LabelContentAsset.Value.Presentation.LabelItem.Descriptors
    
    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let interactor: PasteboardLabelContentInteracting
    private let disposeBag = DisposeBag()
    
    init(interactor: PasteboardLabelContentInteracting,
         descriptors: PresentationDescriptors) {
        self.interactor = interactor
        let successDescriptors: PresentationDescriptors = .success(
            fontSize: descriptors.titleFontSize,
            accessibilityIdSuffix: descriptors.accessibilityIdSuffix
        )
        let descriptorObservable: Observable<PresentationDescriptors> = interactor.isPasteboarding
            .map { $0 ? successDescriptors : descriptors }
            .flatMap { Observable.just($0) }
            
        Observable
            .combineLatest(interactor.state, descriptorObservable)
            .map { .init(with: $0.0, descriptors: $0.1) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
