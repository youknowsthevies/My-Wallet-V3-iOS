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
    
    // MARK: - LabelContent
    
    public let descriptionLabelContent: Driver<LabelContent>
         
    public var containsDescription: Driver<Bool> {
        interactor.contentCalculationState
            .map { $0.isValue }
            .asDriver(onErrorJustReturn: false)
    }
    
    public let titleLabelContent: LabelContent
    
    // MARK: - Tap Interaction
    
    public var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    public let tapRelay = PublishRelay<Void>()
    
    // MARK: - Interactor

    private let interactor: ContentLabelViewInteractorAPI
    
    // MARK: - Init
    
    public init(title: String,
                alignment: NSTextAlignment,
                interactor: ContentLabelViewInteractorAPI) {
        self.interactor = interactor
        titleLabelContent = .init(
            text: title,
            font: .main(.medium, 12),
            color: .secondary,
            alignment: alignment,
            accessibility: .id(Accessibility.Identifier.ContentLabelView.title)
        )
        descriptionLabelContent = interactor.contentCalculationState
            .compactMap { $0.value }
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 14),
                    color: .titleText,
                    alignment: alignment,
                    accessibility: .id(AccessibilityId.description)
                )
            }
            .asDriver(onErrorJustReturn: .empty)
    }
}
