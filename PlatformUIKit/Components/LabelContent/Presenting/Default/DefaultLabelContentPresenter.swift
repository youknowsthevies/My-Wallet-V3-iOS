//
//  DefaultLabelContentPresenter.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxRelay
import RxSwift

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

    public let interactor: LabelContentInteracting
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
        self.init(
            interactor: DefaultLabelContentInteractor(knownValue: knownValue),
            descriptors: descriptors
        )
    }

    public convenience init(descriptors: Descriptors) {
        self.init(
            interactor: DefaultLabelContentInteractor(),
            descriptors: descriptors
        )
    }
}
