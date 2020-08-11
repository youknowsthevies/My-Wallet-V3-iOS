//
//  ContentLabelViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel on 06/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa
import ToolKit
import PlatformKit

public final class ContentLabelViewPresenter {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.ContentLabelView
    
    public var descriptionLabelContent: Driver<LabelContent> {
        descriptionLabelContentRelay.asDriver()
    }
         
    public var containsDescription: Driver<Bool> {
        interactor.contentCalculationState
            .map { $0.isValue }
            .asDriver(onErrorJustReturn: false)
    }
    
    public let titleLabelContent: LabelContent
    
    private let descriptionLabelContentRelay: BehaviorRelay<LabelContent>
    private let interactor: ContentLabelViewInteractorAPI & Interactable
    private let disposeBag = DisposeBag()
    
    public init(title: String, interactor: ContentLabelViewInteractorAPI) {
        self.interactor = interactor
        titleLabelContent = LabelContent(
            text: title,
            font: .main(.medium, 12),
            color: .descriptionText,
            accessibility: .id(AccessibilityId.title)
        )
        
        descriptionLabelContentRelay = BehaviorRelay(value: .empty)
        interactor.contentCalculationState
            .compactMap { $0.value }
            .map {
                LabelContent(
                    text: $0,
                    font: .main(.semibold, 14),
                    color: .titleText,
                    accessibility: .id(AccessibilityId.description)
                )
            }
            .bindAndCatch(to: descriptionLabelContentRelay)
            .disposed(by: disposeBag)
    }
}
