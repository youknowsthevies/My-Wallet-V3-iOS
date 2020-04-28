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
    
    struct CardDataViewModel {
        let data: CardData
        let max: FiatValue
    }
    
    // MARK: - Private Types
    
    private typealias LocalizationIDs = LocalizationConstants.Settings.Badge
    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.LinkedCardCell

    // MARK: - Public
    
    
    var data: CardData {
        viewModel.data
    }
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
    
    private let badgeVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    private let viewModel: CardDataViewModel
    
    init(acceptsUserInteraction: Bool, viewModel: CardDataViewModel) {
        self.viewModel = viewModel
        
        linkedCardViewModel = .init(type: viewModel.data.type)
        let data = viewModel.data
        let currencyCode = data.topLimit.currencyCode
        let limitAmount = data.topLimitDisplayValue
        let limitDisplayValue = limitAmount + " \(currencyCode) \(LocalizationIDs.limit)"
        
        linkedCardViewModel.content = .init(theme:
            .init(
                cardName: viewModel.data.label,
                limit: limitDisplayValue
            )
        )

        self.acceptsUserInteraction = acceptsUserInteraction

        expirationLabelContent = .init(
            text: "\(LocalizationIDs.expires) " + data.displayExpirationDate,
            font: .mainMedium(14.0),
            color: .descriptionText,
            alignment: .right,
            accessibility: .id(AccessibilityIDs.expiration)
        )
        
        let state = viewModel.data.state
        
        let accessibilityId = "\(viewModel.data.type).\(state.rawValue)"
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
            badgeVisibilityRelay.accept(viewModel.data.state == .active ? .hidden: .visible)
        }
        
        digitsLabelContent = .init(
            text: viewModel.data.displaySuffix,
            font: .mainSemibold(16.0),
            color: .textFieldText,
            alignment: .right,
            accessibility: .id(AccessibilityIDs.cardPrefix)
        )
    }
}
