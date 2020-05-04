//
//  DetailsScreen.swift
//  PlatformUIKit
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum DetailsScreen {

    public enum BarButtonAction {
        /// Uses default action from view controller
        case `default`
        /// Uses custom action
        case custom(() -> Void)
    }

    public enum CellType {
        case label(LabelContent)
        case notice(NoticeViewModel)
        case lineItem(LineItemCellPresenting)
        case separator
        case interactableTextCell(InteractableTextViewModel)
    }

    public enum NavigationBarAppearance {
        case defaultDark
        case custom(leading: Screen.Style.LeadingButton, trailing: Screen.Style.TrailingButton, barStyle: Screen.Style.Bar)
    }
}
