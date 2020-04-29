//
//  UILabel+LabelContent.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public extension UILabel {
    var content: LabelContent {
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            textAlignment = newValue.alignment
            accessibility = newValue.accessibility
        }
        get {
            LabelContent(
                text: text ?? "",
                font: font,
                color: textColor,
                alignment: textAlignment,
                accessibility: accessibility
            )
        }
    }
}

public extension Reactive where Base: UILabel {
    var content: Binder<LabelContent> {
        Binder(base) { $0.content = $1 }
    }
}
