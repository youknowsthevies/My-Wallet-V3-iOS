//
//  PasteboardLabelContentInteractor.swift
//  Blockchain
//
//  Created by AlexM on 1/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import PlatformUIKit
import PlatformKit

/// A protocol for `UILabels` whose content can be copied to the clipboard.
protocol PasteboardLabelContentInteracting: LabelContentInteracting {
    var pasteboardTriggerRelay: PublishRelay<Void> { get }
    var isPasteboarding: BehaviorRelay<Bool> { get }
}

final class PasteboardLabelContentInteractor: PasteboardLabelContentInteracting {
    
    // MARK: - Types
    
    typealias InteractionState = LabelContentAsset.State.LabelItem.Interaction
    
    /// A `PublishRelay` that triggers the applying of the `interactionText`.
    /// After the `interactionDuration` has passed (in seconds) the original
    /// text will be shown.
    var pasteboardTriggerRelay = PublishRelay<Void>()
    
    /// Returns whether or not the pasteboarding effect is still visible.
    /// Effect lasts as long as the `interactionDuration` provided.
    var isPasteboarding = BehaviorRelay(value: false)
    
    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        return stateRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Setup
    
    init(text: String, interactionText: String, interactionDuration: Int) {
        stateRelay.accept(.loaded(next: .init(text: text)))
        
        pasteboardTriggerRelay
            .map { .loaded(next: .init(text: interactionText)) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        pasteboardTriggerRelay
            .debounce(
                .seconds(interactionDuration),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated)
            )
            .map { .loaded(next: .init(text: text)) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
        
        stateRelay
            .compactMap { $0.value?.text }
            .map { $0 == interactionText }
            .bind(to: isPasteboarding)
            .disposed(by: disposeBag)
    }
}

