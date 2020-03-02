//
//  DefaultLineItemCellPresenter.swift
//  Blockchain
//
//  Created by AlexM on 1/29/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

final class DefaultLineItemCellInteractor {
    let title: DefaultLabelContentInteractor
    let description: DefaultLabelContentInteractor
    
    init(title: DefaultLabelContentInteractor = DefaultLabelContentInteractor(),
         description: DefaultLabelContentInteractor = DefaultLabelContentInteractor()) {
        self.title = title
        self.description = description
    }
}

final class DefaultLineItemCellPresenter: LineItemCellPresenting {
    
    // MARK: - Types
    
    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout.LineItem
    
    // MARK: - Properties
    
    var image: Driver<UIImage?> {
        return imageRelay.asDriver()
    }
    
    /// The background color relay
    let imageRelay = BehaviorRelay<UIImage?>(value: nil)
    
    var backgroundColor: Driver<UIColor> {
        return backgroundColorRelay.asDriver()
    }
    
    /// The background color relay
    let backgroundColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    let titleLabelContentPresenter: LabelContentPresenting
    let descriptionLabelContentPresenter: LabelContentPresenting
    
    /// MARK: - Injected
    
    let interactor: DefaultLineItemCellInteractor
    
    // MARK: - Init
    
    init(interactor: DefaultLineItemCellInteractor) {
        self.interactor = interactor
        titleLabelContentPresenter = DefaultLabelContentPresenter.title(
            interactor: interactor.title
        )
        descriptionLabelContentPresenter = DefaultLabelContentPresenter.description(
            interactor: interactor.description
        )
    }
}
