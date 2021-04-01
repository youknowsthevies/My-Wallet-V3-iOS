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

/// Presenter for `ContentLabelView`.
final class ContentLabelViewPresenter {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.ContentLabelView

    // MARK: - Title LabelContent

    /// An input relay for the title.
    let titleRelay: BehaviorRelay<String>

    /// Driver emitting the title `LabelContent`.
    let titleLabelContent: Driver<LabelContent>

    // MARK: - Description LabelContent

    let descriptionLabelContent: Driver<LabelContent>

    var containsDescription: Driver<Bool> {
        interactor.contentCalculationState
            .map { $0.isValue }
            .asDriver(onErrorJustReturn: false)
    }
    
    // MARK: - Tap Interaction
    
    var tap: Signal<Void> {
        tapRelay.asSignal()
    }
    
    let tapRelay = PublishRelay<Void>()
    
    // MARK: - Interactor

    private let interactor: ContentLabelViewInteractorAPI
    
    // MARK: - Init
    
    init(title: String,
         alignment: NSTextAlignment,
         interactor: ContentLabelViewInteractorAPI) {
        self.interactor = interactor
        titleRelay = BehaviorRelay<String>(value: title)
        titleLabelContent = titleRelay
            .asDriver()
            .map { title in
                LabelContent(
                    text: title,
                    font: .main(.medium, 12),
                    color: .secondary,
                    alignment: alignment,
                    accessibility: .id(Accessibility.Identifier.ContentLabelView.title)
                )
            }
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
