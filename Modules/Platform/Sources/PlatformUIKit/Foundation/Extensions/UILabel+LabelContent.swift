// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension UILabel {
    public var content: LabelContent {
        get {
            LabelContent(
                text: text ?? "",
                font: font,
                color: textColor,
                alignment: textAlignment,
                lineSpacing: 1,
                lineBreakMode: lineBreakMode,
                adjustsFontSizeToFitWidth: adjustsFontSizeToFitWidth ? .true(factor: minimumScaleFactor) : .false,
                accessibility: accessibility
            )
        }
        set {
            // Set Accessibility
            accessibility = newValue.accessibility.copy(label: newValue.text)

            // Set Font and Text Color properties.
            font = newValue.font
            textColor = newValue.color

            // Set new text
            text = newValue.text

            // Get the attributedText that was just generated.
            let mutableAttributedString = attributedText.flatMap(NSMutableAttributedString.init)
                ?? NSMutableAttributedString(string: newValue.text)

            // Set lineSpacing.
            mutableAttributedString.add(lineSpacing: newValue.lineSpacing)
            // Set attributedText.
            attributedText = mutableAttributedString

            // Set style-related properties.
            textAlignment = newValue.alignment
            lineBreakMode = newValue.lineBreakMode
            switch newValue.adjustsFontSizeToFitWidth {
            case .false:
                adjustsFontSizeToFitWidth = false
                minimumScaleFactor = 1
            case .true(factor: let factor):
                adjustsFontSizeToFitWidth = true
                minimumScaleFactor = factor
            }

            // Size to fit.
            sizeToFit()
        }
    }
}

extension Reactive where Base: UILabel {
    public var content: Binder<LabelContent> {
        Binder(base) { view, content in
            view.content = content
        }
    }
}
