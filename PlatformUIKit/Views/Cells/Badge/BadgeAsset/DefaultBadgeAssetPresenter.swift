//
//  BadgeAssetPresenting.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class DefaultBadgeAssetPresenter: BadgeAssetPresenting {
    public typealias PresentationState = BadgeAsset.State.BadgeItem.Presentation

    public var state: Observable<PresentationState> {
        stateRelay.asObservable()
    }

    public let interactor: BadgeAssetInteracting
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    public init(interactor: BadgeAssetInteracting = DefaultBadgeAssetInteractor()) {
        self.interactor = interactor
        interactor.state
            .map { .init(with: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
