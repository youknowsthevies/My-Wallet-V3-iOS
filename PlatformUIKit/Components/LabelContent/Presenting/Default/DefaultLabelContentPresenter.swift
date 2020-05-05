//
//  DefaultLabelContentPresenter.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformKit

public final class DefaultLabelContentPresenter: LabelContentPresenting {

    // MARK: - Types

    public typealias PresentationState = LabelContent.State.Presentation
    public typealias Descriptors = LabelContent.Value.Presentation.Content.Descriptors

    // MARK: - LabelContentPresenting

    public let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    public var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    private let interactor: LabelContentInteracting
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(interactor: LabelContentInteracting, descriptors: Descriptors) {
        self.interactor = interactor
        interactor.state
            .map { .init(with: $0, descriptors: descriptors) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)

    }

    public convenience init(knownValue: String, descriptors: Descriptors) {
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

    public static func description(interactor: LabelContentInteracting) -> DefaultLabelContentPresenter {
        DefaultLabelContentPresenter(
            interactor: interactor,
            descriptors: .lineItemDescription
        )
    }

    public static func title(interactor: LabelContentInteracting) -> DefaultLabelContentPresenter {
        DefaultLabelContentPresenter(
            interactor: interactor,
            descriptors: .lineItemTitle
        )
    }

    public static func disclaimer(interactor: LabelContentInteracting) -> DefaultLabelContentPresenter {
        DefaultLabelContentPresenter(
            interactor: interactor,
            descriptors: .init(
                contentColor: .descriptionText,
                fontSize: 12,
                accessibilityIdSuffix: AccessibilityId.disclaimerLabel
            )
        )
    }
}
