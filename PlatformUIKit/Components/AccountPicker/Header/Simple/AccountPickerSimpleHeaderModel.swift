//
//  AccountPickerSimpleHeaderModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 14/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct AccountPickerSimpleHeaderModel {
    static let defaultHeight: CGFloat = 120

    private let title: String
    private let subtitle: String

    var titleLabel: LabelContent {
        LabelContent(
            text: title,
            font: .main(.semibold, 20),
            color: .titleText
        )
    }

    var subtitleLabel: LabelContent {
        LabelContent(
            text: subtitle,
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
