// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public extension UILabel {
    var content: LabelContent {
        get {
            LabelContent(
                text: text ?? "",
                font: font,
                color: textColor,
                alignment: textAlignment,
                accessibility: accessibility
            )
        }
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            textAlignment = newValue.alignment
            accessibility = newValue.accessibility.copy(label: newValue.text)
        }
    }
}

public extension Reactive where Base: UILabel {
    var content: Binder<LabelContent> {
        Binder(base) { $0.content = $1 }
    }
}
