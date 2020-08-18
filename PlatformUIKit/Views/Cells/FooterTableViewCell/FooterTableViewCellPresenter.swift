//
//  FooterTableViewCellPresenter.swift
//  PlatformUIKit
//
//  Created by Alex McGregor on 8/12/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class FooterTableViewCellPresenter {
    
    public var identifier: String {
        content.text
    }
    
    public let content: LabelContent
    
    public init(text: String,
                accessibility: Accessibility) {
        content = .init(
            text: text,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .center,
            accessibility: accessibility
        )
    }
}
