//
//  LineItemCellPresenting.swift
//  PlatformUIKit
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import RxCocoa
import ToolKit
import PlatformKit

public protocol LineItemCellPresenting: AnyObject {

    var interactor: LineItemCellInteracting { get }

    /// The `LabelContentPresenting` for the title of the `LineItem`
    var titleLabelContentPresenter: LabelContentPresenting { get }

    /// The `LabelContentPresenting` for the description of the `LineItem`
    var descriptionLabelContentPresenter: LabelContentPresenting { get }

    /// Some `LineItems` have an image (e.g. clipboard).
    var image: Driver<UIImage?> { get }

    /// Some `LineItems` have a different background color (e.g. clipboard
    /// on selection).
    var backgroundColor: Driver<UIColor> { get }

    /// Accepts tap from a view
    var tapRelay: PublishRelay<Void> { get }
}

public protocol LineItemCellInteracting: AnyObject {

    var title: LabelContentInteracting { get }

    var description: LabelContentInteracting { get }
}
