//
//  TitledSeparatorViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel on 19/06/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct TitledSeparatorViewModel {
    let titleLabelContent: LabelContent
    let separatorColor: Color
    let accessibility: Accessibility
    
    public init(title: String, accessibilityId: String) {
        titleLabelContent = LabelContent(
            text: title,
            font: .main(.semibold, 12),
            color: .titleText
        )
        separatorColor = .lightBorder
        accessibility = .id(accessibilityId)
    }
}
