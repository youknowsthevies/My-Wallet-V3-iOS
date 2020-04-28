//
//  AddCardBadgePresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/8/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import PlatformUIKit
import RxSwift
import RxCocoa

final class AddCardBadgePresenter: BadgeImageAssetPresenting {
    
    typealias BadgeImageState = LoadingState<BadgeImageViewModel>
    
    var state: Observable<BadgeImageState> {
        stateRelay.asObservable()
    }
    
    private let cardListService: CardListServiceAPI
    private let tiersLimitsProviding: TierLimitsProviding
    private let stateRelay = BehaviorRelay<BadgeImageState>(value: .loading)
    private let disposeBag = DisposeBag()
    private var isKYCVerified: Observable<Bool> {
        tiersLimitsProviding
            .tiers
            .map { $0.isTier2Approved }
            .catchErrorJustReturn(false)
    }
    private var cards: Observable<[CardData]> {
        cardListService.cards.catchErrorJustReturn([])
    }
    
    init(service: CardListServiceAPI, tierLimitsProviding: TierLimitsProviding) {
        self.tiersLimitsProviding = tierLimitsProviding
        self.cardListService = service
        setup()
    }
    
    private func setup() {
        Observable.combineLatest(cards, isKYCVerified)
            .map { $0.0.count < 3 && $0.1 }
            .map { $0 ? .card : .info }
            .map { .loaded(next: $0) }
            .bind(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

fileprivate extension BadgeImageViewModel {
    static let card: BadgeImageViewModel = .primary(
        with: "Icon-Creditcard",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )
    
    static let info: BadgeImageViewModel = .default(
        with: "Icon-Information",
        cornerRadius: .round,
        accessibilityIdSuffix: ""
    )
}
