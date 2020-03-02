//
//  LabeledButtonViewStyle.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 28/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public struct LabeledButtonViewStyle {
    let backgroundColor: Color
    let font: UIFont
    let textColor: Color
}

extension LabeledButtonViewStyle {
    public static var currency: LabeledButtonViewStyle {
        return .init(
            backgroundColor: .mediumBackground,
            font: .mainMedium(16),
            textColor: .titleText
        )
    }
}
