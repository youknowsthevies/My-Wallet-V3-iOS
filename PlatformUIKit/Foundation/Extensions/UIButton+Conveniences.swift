//
//  UIButton+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct ButtonContent: Equatable {
    
    public static let defaultFont: UIFont = .systemFont(ofSize: 12)
    public static let defaultColor: UIColor = .clear

    public static var empty: ButtonContent {
        return ButtonContent()
    }
    
    let text: String
    let font: UIFont
    let color: UIColor
    let accessibility: Accessibility
    
    public init(text: String = "",
                font: UIFont = ButtonContent.defaultFont,
                color: UIColor = ButtonContent.defaultColor,
                accessibility: Accessibility = .none) {
        self.text = text
        self.font = font
        self.color = color
        self.accessibility = accessibility
    }
    
    public static func == (lhs: ButtonContent, rhs: ButtonContent) -> Bool {
        return lhs.text == rhs.text
    }
    
    public func isEmpty() -> Bool {
        return text == ""
    }
}

extension UIButton {
    public var content: ButtonContent {
        set {
            setTitle(newValue.text, for: .normal)
            titleLabel?.font = newValue.font
            setTitleColor(newValue.color, for: .normal)
            accessibility = newValue.accessibility
        }
        get {
            return ButtonContent(
                text: title(for: .normal) ?? "",
                font: titleLabel?.font ?? ButtonContent.defaultFont,
                color: titleColor(for: .normal) ?? ButtonContent.defaultColor,
                accessibility: accessibility
            )
        }
    }
}

extension Reactive where Base: UIButton {
    public var content: Binder<ButtonContent> {
        return Binder(base) { button, content in
            button.content = content
        }
    }
}
