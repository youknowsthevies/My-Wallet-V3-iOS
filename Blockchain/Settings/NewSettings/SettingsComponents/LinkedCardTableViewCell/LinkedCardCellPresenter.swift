//
//  LinkedCardCellPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit
import RxSwift
import RxRelay
import RxCocoa

final class LinkedCardCellPresenter {
    
    // MARK: - Private Types
    
    private typealias LocalizationIDs = LocalizationConstants.Settings.Badge
    
    // MARK: - Public
    
    // TODO: Placeholder
    let linkedCardViewModel: LinkedCardViewModel = .visa(
        cardName: "Chase Saphire Visa",
        limit: .init(minor: "5000000", currency: .USD)
    )
    
    // TODO: Placeholder
    let digitsLabelContent: LabelContent = .init(
        text: "•••• 8291",
        font: .mainSemibold(16.0),
        color: .textFieldText,
        alignment: .right,
        accessibility: .none
    )
    
    // TODO: Placeholder
    let expirationLabelContent: LabelContent = .init(
        text: "Exp: 04/2024",
        font: .mainMedium(14.0),
        color: .descriptionText,
        alignment: .right,
        accessibility: .none
    )
    
    let expiredBadgeViewModel: BadgeViewModel = .destructive(with: LocalizationIDs.expired)
    
    var expiredBadgeVisibility: Driver<Visibility> {
        expiredBadgeVisibilityRelay.asDriver()
    }
    
    private let expiredBadgeVisibilityRelay = BehaviorRelay<Visibility>(value: .hidden)
    
}
