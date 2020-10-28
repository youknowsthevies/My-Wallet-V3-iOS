//
//  ContentLabelViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

public final class ContentLabelViewPresenter {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.ContentLabelView
    
    public let descriptionLabelContent: Driver<LabelContent>
         
    public var containsDescription: Driver<Bool> {
        interactor.contentCalculationState
            .map { $0.isValue }
            .asDriver(onErrorJustReturn: false)
    }
    
    public let titleLabelContent: LabelContent

    private let interactor: ContentLabelViewInteractorAPI
    
    public init(title: String, interactor: ContentLabelViewInteractorAPI) {
        self.interactor = interactor
        titleLabelContent = LabelContent(
            text: title,
            font: .main(.medium, 12),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.title)
        )

        descriptionLabelContent = interactor.contentCalculationState
            .compactMap { $0.value }
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 14),
                    color: .titleText,
                    accessibility: .id(AccessibilityId.description)
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }
}
