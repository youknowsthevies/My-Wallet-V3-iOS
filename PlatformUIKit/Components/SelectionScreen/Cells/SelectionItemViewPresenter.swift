//
//  SelectionItemViewPresenter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 30/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay
import ToolKit
import PlatformKit

final class SelectionItemViewPresenter {
    
    // MARK: - Types
    
    private typealias AccessibilityId = Accessibility.Identifier.SelectionScreen
    
    // MARK: - Exposed Properties
    
    let image: ImageViewContent
    let title: LabelContent
    let description: LabelContent

    let accessibility: Accessibility
    
    var selectionImage: Observable<ImageViewContent> {
        isSelectedRelay
            .map(weak: self) { (self, isSelected) -> ImageViewContent in
                guard isSelected else { return .empty }
                let item = self.interactor.item
                return ImageViewContent(
                    imageName: "v-selection-icon",
                    accessibility: .id("\(AccessibilityId.selectionImageViewPrefix)\(item.accessibilityId)")
                )
            }
    }
    
    var data: SelectionItemViewModel {
        interactor.item
    }
    
    // MARK: - Private Properties
    
    private let isSelectedRelay = BehaviorRelay(value: false)
    private let interactor: SelectionItemViewInteractor
    private let disposeBag = DisposeBag()
    
    init(interactor: SelectionItemViewInteractor) {
        self.interactor = interactor
        let item = interactor.item
        accessibility = .id("\(AccessibilityId.selectionCellPrefix)\(item.id)")
        switch item.thumbImage {
        case .name(let name):
            image = ImageViewContent(
                imageName: name,
                accessibility: .id("\(AccessibilityId.imageViewPrefix)\(item.accessibilityId)")
            )
        case .none:
            image = .empty
        }

        title = LabelContent(
            text: item.name,
            font: .mainSemibold(16),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.titleLabelPrefix)\(item.accessibilityId)")
        )
        description = LabelContent(
            text: item.description,
            font: .mainMedium(14),
            color: .titleText,
            accessibility: .id("\(AccessibilityId.descriptionLabelPrefix)\(item.accessibilityId)")
        )
        
        isSelectedRelay
            .bind(to: interactor.isSelectedRelay)
            .disposed(by: disposeBag)
    }
    
    func select() {
        isSelectedRelay.accept(true)
    }
    
    func deselect() {
        isSelectedRelay.accept(false)
    }
}
