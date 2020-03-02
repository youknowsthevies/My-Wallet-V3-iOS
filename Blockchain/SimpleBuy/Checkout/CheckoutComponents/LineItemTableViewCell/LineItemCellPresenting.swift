//
//  LineItemCellPresenting.swift
//  Blockchain
//
//  Created by AlexM on 1/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift
import RxCocoa
import ToolKit
import PlatformKit
import PlatformUIKit

protocol LineItemCellPresenting: class {
    
    /// The `LabelContentPresenting` for the title of the `LineItem`
    var titleLabelContentPresenter: LabelContentPresenting { get }
    
    /// The `LabelContentPresenting` for the description of the `LineItem`
    var descriptionLabelContentPresenter: LabelContentPresenting { get }
    
    /// Some `LineItems` have an image (e.g. clipboard).
    var image: Driver<UIImage?> { get }
    
    /// Some `LineItems` have a different background color (e.g. clipboard
    /// on selection).
    var backgroundColor: Driver<UIColor> { get }
}
