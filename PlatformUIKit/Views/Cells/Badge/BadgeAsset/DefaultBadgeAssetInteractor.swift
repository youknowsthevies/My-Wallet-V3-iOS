//
//  BadgeAssetInteracting.swift
//  Blockchain
//
//  Created by AlexM on 12/16/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

open class DefaultBadgeAssetInteractor: BadgeAssetInteracting {
    public typealias InteractionState = BadgeAsset.State.BadgeItem.Interaction
    public typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem

    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    public let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    public let disposeBag = DisposeBag()

    public init() { }
}
