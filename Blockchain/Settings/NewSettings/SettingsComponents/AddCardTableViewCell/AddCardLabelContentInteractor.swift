//
//  AddCardLabelContentInteractor.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import PlatformKit
import RxSwift
import RxRelay

final class AddCardLabelContentInteractor: LabelContentInteracting {
    
    // MARK: - Types
    
    typealias LocalizationString = LocalizationConstants.Settings.Cards
    typealias InteractionState = LabelContent.State.Interaction
    typealias Descriptors = LabelContent.Value.Presentation.Content.Descriptors
    
    // MARK: - Properties
    
    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }
    
    let descriptorRelay = BehaviorRelay<Descriptors>(value: .settings)
    var descriptorObservable: Observable<Descriptors> {
        descriptorRelay.asObservable()
    }
    
    // MARK: - Private Accessors
    
    private let disposeBag = DisposeBag()
    private let tierLimitsProviding: TierLimitsProviding
    private let cardListService: CardListServiceAPI
    private var isKYCVerified: Observable<Bool> {
        tierLimitsProviding
            .tiers
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
    }
    private var cards: Observable<[CardData]> {
        cardListService.cards.catchErrorJustReturn([])
    }
    
    // MARK: - Setup
    
    init(service: CardListServiceAPI, tierLimitsProviding: TierLimitsProviding) {
        self.cardListService = service
        self.tierLimitsProviding = tierLimitsProviding
        setup()
    }
    
    private func setup() {
        Observable.combineLatest(cards, isKYCVerified)
            .map { ($0.0.count < 3 && $0.1) }
            .map { $0 ? .settings : .disclaimer }
            .bind(to: descriptorRelay)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(cards, isKYCVerified)
            .map { ($0.0.count < 3, $0.1) }
            .map { values in
                let underLimit = values.0
                let isKYCVerified = values.1
                guard isKYCVerified else { return LocalizationString.unverified }
                return underLimit ? LocalizationString.addACard : LocalizationString.maximum
            }
            .map { .loaded(next: .init(text: $0)) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
