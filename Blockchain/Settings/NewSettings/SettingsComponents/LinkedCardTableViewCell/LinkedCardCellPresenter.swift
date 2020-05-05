//
//  LinkedCardCellPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

final class LinkedCardCellPresenter {
    
    // MARK: - Private Types
    
    private typealias LocalizationIDs = LocalizationConstants.Settings.Badge
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.LinkedCardCell

    // MARK: - Public
        
    let accessibility: Accessibility = .id(AccessibilityIDs.view)
    let linkedCardViewModel: LinkedCardViewModel
    let digitsLabelContent: LabelContent
    let expirationLabelContent: LabelContent
    let acceptsUserInteraction: Bool
    
    let badgeViewModel: BadgeViewModel
    
    var badgeVisibility: Driver<Visibility> {
        badgeVisibilityRelay.asDriver()
    }
    
    let tapRelay = PublishRelay<Void>()
    var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    let cardData: CardData
    
    private let badgeVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    
    init(acceptsUserInteraction: Bool, cardData: CardData) {
        self.cardData = cardData
        
        linkedCardViewModel = .init(type: cardData.type)
        let currencyCode = cardData.topLimit.currencyCode
        let limitAmount = cardData.topLimitDisplayValue
        let limitDisplayValue = limitAmount + " \(currencyCode) \(LocalizationIDs.limit)"
        
        linkedCardViewModel.content = .init(theme:
            .init(
                cardName: cardData.label,
                limit: limitDisplayValue
            )
        )

        self.acceptsUserInteraction = acceptsUserInteraction

        expirationLabelContent = .init(
            text: "\(LocalizationIDs.expires) " + cardData.displayExpirationDate,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .right,
            accessibility: .id(AccessibilityIDs.expiration)
        )
        
        let state = cardData.state
        
        let accessibilityId = "\(cardData.type).\(state.rawValue)"
        switch state {
        case .created, .pending:
            badgeViewModel = .default(
                with: LocalizationIDs.pending,
                accessibilityId: accessibilityId
            )
        case .blocked, .expired:
            badgeViewModel = .destructive(
                with: LocalizationIDs.expired,
                accessibilityId: accessibilityId
            )
        case .fraudReview, .manualReview:
            badgeViewModel = .default(
                with: LocalizationIDs.inReview,
                accessibilityId: LocalizationIDs.inReview
            )
        case .none, .active:
            badgeViewModel = .default(
                with: LocalizationIDs.unknown,
                accessibilityId: accessibilityId
            )
        }
        
        badgeVisibilityRelay.accept(cardData.state == .active ? .hidden: .visible)
        
        digitsLabelContent = .init(
            text: cardData.displaySuffix,
            font: .main(.semibold, 16.0),
            color: .textFieldText,
            alignment: .right,
            accessibility: .id(AccessibilityIDs.cardPrefix)
        )
    }
}
