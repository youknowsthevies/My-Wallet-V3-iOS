//
//  ScreenNavigationModel.swift
//  PlatformUIKit
//
//  Created by Paulo on 28/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct ScreenNavigationModel {
    let leadingButton: Screen.Style.LeadingButton
    let trailingButton: Screen.Style.TrailingButton
    let barStyle: Screen.Style.Bar
    let titleViewStyle: Screen.Style.TitleView
    
    public init(leadingButton: Screen.Style.LeadingButton,
                trailingButton: Screen.Style.TrailingButton,
                titleViewStyle: Screen.Style.TitleView,
                barStyle: Screen.Style.Bar) {
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.titleViewStyle = titleViewStyle
        self.barStyle = barStyle
    }
}

extension ScreenNavigationModel {
    public static let noneDark = ScreenNavigationModel(
        leadingButton: .none,
        trailingButton: .none,
        titleViewStyle: .none,
        barStyle: .darkContent()
    )
}
