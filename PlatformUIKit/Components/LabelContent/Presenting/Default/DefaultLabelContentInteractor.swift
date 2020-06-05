//
//  DefaultLabelContentInteractor.swift
//  PlatformUIKit
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RxSwift
import RxRelay

public final class DefaultLabelContentInteractor: LabelContentInteracting {
    
    // MARK: - Types
    
    public typealias InteractionState = LabelContent.State.Interaction
    
    // MARK: - LabelContentInteracting
    
    public let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    public init(knownValue: String) {
        stateRelay.accept(.loaded(next: .init(text: knownValue)))
    }
    
    public init() {}
}
