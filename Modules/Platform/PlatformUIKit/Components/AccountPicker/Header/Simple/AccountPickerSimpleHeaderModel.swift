//
//  AccountPickerSimpleHeaderModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 14/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct AccountPickerSimpleHeaderModel {
    static let defaultHeight: CGFloat = 64

    private let subtitle: String

    var subtitleLabel: LabelContent {
        LabelContent(
            text: subtitle,
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    public init(subtitle: String) {
        self.subtitle = subtitle
    }
}
