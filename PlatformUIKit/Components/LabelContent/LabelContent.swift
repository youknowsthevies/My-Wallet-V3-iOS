//
//  LabelContent.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 25/10/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxCocoa

public struct LabelContent: Equatable {

    public static var empty: LabelContent {
        LabelContent()
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
                font: UIFont = .main(.regular, 12),
                color: UIColor = .clear,
                alignment: NSTextAlignment = .natural,
                accessibility: Accessibility = .none) {
        self.text = text
        self.font = font
        self.color = color
        self.alignment = alignment
        self.accessibility = accessibility
    }

    public static func ==(lhs: LabelContent, rhs: LabelContent) -> Bool {
        lhs.text == rhs.text
    }
}
