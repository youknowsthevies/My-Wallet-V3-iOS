//
//  ExplainedActionViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel on 16/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct ExplainedActionViewModel {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.ExplainedActionView
    
    // MARK: - Setup
    
    let thumbBadgeImageViewModel: BadgeImageViewModel
    let titleLabelContent: LabelContent
    let descriptionLabelContents: [LabelContent]
    let badgeViewModel: BadgeViewModel?

    // MARK: - Accessors
    
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    let tapRelay = PublishRelay<Void>()
    
    // MARK: - Setup
    
    public init(thumbImage: String,
                title: String,
                descriptions: [String],
                badgeTitle: String?,
                uniqueAccessibilityIdentifier: String) {
        thumbBadgeImageViewModel = .primary(
            with: thumbImage,
            cornerRadius: .round,
            accessibilityIdSuffix: uniqueAccessibilityIdentifier
        )
        thumbBadgeImageViewModel.marginOffsetRelay.accept(6)
        titleLabelContent = .init(
            text: title,
            font: .main(.semibold, 16),
            color: .titleText,
            accessibility: .id(uniqueAccessibilityIdentifier + AccessibilityId.titleLabel)
        )
        descriptionLabelContents = descriptions
            .enumerated()
            .map { payload in
                .init(
                    text: payload.element,
                    font: .main(.medium, 14),
                    color: .descriptionText,
                    accessibility: .id(uniqueAccessibilityIdentifier + AccessibilityId.descriptionLabel + ".\(payload.offset)")
                )
            }
        
        if let badgeTitle = badgeTitle {
            badgeViewModel = .affirmative(
                with: badgeTitle,
                accessibilityId: uniqueAccessibilityIdentifier + AccessibilityId.badgeView
            )
        } else { // hide badge
            badgeViewModel = nil
        }
    }
}

extension ExplainedActionViewModel: Equatable {
    public static func == (lhs: ExplainedActionViewModel, rhs: ExplainedActionViewModel) -> Bool {
        lhs.badgeViewModel == rhs.badgeViewModel
            && lhs.titleLabelContent == rhs.titleLabelContent
            && lhs.thumbBadgeImageViewModel == rhs.thumbBadgeImageViewModel
            && lhs.descriptionLabelContents == rhs.descriptionLabelContents
    }
}
