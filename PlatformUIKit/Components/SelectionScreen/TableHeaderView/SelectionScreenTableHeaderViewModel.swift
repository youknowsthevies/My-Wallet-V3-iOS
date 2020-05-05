//
//  SelectionScreenTableHeaderViewModel.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 4/1/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct SelectionScreenTableHeaderViewModel {
    
    /// The content color relay
    let contentColorRelay = BehaviorRelay<UIColor>(value: .clear)
    
    /// The content color of the title
    var contentColor: Driver<UIColor> {
        return contentColorRelay.asDriver()
    }
    
    /// The text relay
    let textRelay = BehaviorRelay<String>(value: "")
    
    /// Text to be displayed on the badge
    var text: Driver<String> {
        return textRelay.asDriver()
    }
    
    let font: UIFont
    
    public init?(font: UIFont = .main(.medium, 14), title: String?, textColor: UIColor = .descriptionText) {
        guard let title = title else { return nil }
        self.font = font
        self.textRelay.accept(title)
        self.contentColorRelay.accept(textColor)
    }
}

