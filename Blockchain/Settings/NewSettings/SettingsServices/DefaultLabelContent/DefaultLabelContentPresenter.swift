//
//  DefaultLabelContentPresenter.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit
import PlatformUIKit

final class DefaultLabelContentPresenter: LabelContentPresenting {
    
    // MARK: - Types
    
    typealias PresentationState = LabelContentAsset.State.LabelItem.Presentation
    typealias Descriptors = LabelContentAsset.Value.Presentation.LabelItem.Descriptors
    
    // MARK: - LabelContentPresenting
    
    let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    var state: Observable<PresentationState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let interactor: DefaultLabelContentInteractor
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(interactor: DefaultLabelContentInteractor,
         descriptors: Descriptors) {
        self.interactor = interactor
        interactor.state
            .map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

    }
    
    convenience init(knownValue: String, descriptors: Descriptors) {
        let interactor = DefaultLabelContentInteractor(knownValue: knownValue)
        self.init(
            interactor: interactor,
            descriptors: descriptors
        )
    }
}

// MARK: - Factory Makers

extension DefaultLabelContentPresenter {
    
    private typealias AccessibilityId = Accessibility.Identifier.LineItem
    
    static func description(interactor: DefaultLabelContentInteractor) -> DefaultLabelContentPresenter {
        return .init(
            interactor: interactor,
            descriptors: .lineItemDescription
        )
    }
    
    static func title(interactor: DefaultLabelContentInteractor) -> DefaultLabelContentPresenter {
        return .init(
            interactor: interactor,
            descriptors: .lineItemTitle
        )
    }
    
    static func disclaimer(interactor: DefaultLabelContentInteractor) -> DefaultLabelContentPresenter {
        return DefaultLabelContentPresenter(
            interactor: interactor,
            descriptors: .init(
                contentColor: .descriptionText,
                titleFontSize: 12,
                accessibilityIdSuffix: AccessibilityId.disclaimerLabel
            )
        )
    }
}
