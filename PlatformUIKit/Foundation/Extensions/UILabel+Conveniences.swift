//
//  UILabel+Conveniences.swift
//  Blockchain
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct LabelContent: Equatable {
    
    public static var empty: LabelContent {
        return LabelContent()
    }
    
    public var isEmpty: Bool {
        text.isEmpty
    }
    
    let text: String
    let font: UIFont
    let color: Color
    let alignment: NSTextAlignment
    let accessibility: Accessibility
    
    public init(text: String = "",
                font: UIFont = .systemFont(ofSize: 12),
                color: UIColor = .clear,
                alignment: NSTextAlignment = .natural,
                accessibility: Accessibility = .none) {
        self.text = text
        self.font = font
        self.color = color
        self.alignment = alignment
        self.accessibility = accessibility
    }
    
    public static func == (lhs: LabelContent, rhs: LabelContent) -> Bool {
        return lhs.text == rhs.text
    }
}

extension UILabel {
    public var content: LabelContent {
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            textAlignment = newValue.alignment
            accessibility = newValue.accessibility
        }
        get {
            return LabelContent(
                text: text ?? "",
                font: font,
                color: textColor,
                alignment: textAlignment,
                accessibility: accessibility
            )
        }
    }
}

extension Reactive where Base: UILabel {
    public var content: Binder<LabelContent> {
        return Binder(base) { label, content in
            label.content = content
        }
    }
}
