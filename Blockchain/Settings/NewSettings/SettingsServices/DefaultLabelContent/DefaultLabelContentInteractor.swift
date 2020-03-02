//
//  DefaultLabelContentInteractor.swift
//  Blockchain
//
//  Created by AlexM on 12/19/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class DefaultLabelContentInteractor: LabelContentInteracting {
    
    // MARK: - Types
    
    typealias InteractionState = LabelContentAsset.State.LabelItem.Interaction
    
    // MARK: - LabelContentInteracting
    
    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    init(knownValue: String) {
        stateRelay.accept(.loaded(next: .init(text: knownValue)))
    }
    
    init() {}
}
