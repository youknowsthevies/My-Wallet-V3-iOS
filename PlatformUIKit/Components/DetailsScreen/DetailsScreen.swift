//
//  DetailsScreen.swift
//  PlatformUIKit
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public enum DetailsScreen {

    public enum BarButtonAction {
        /// Uses default action from view controller
        case `default`
        /// Uses custom action
        case custom(() -> Void)
    }

    public enum CellType {
        case badges(MultiBadgeCellModel)
        case buttons([ButtonViewModel])
        case label(LabelContentPresenting)
        case staticLabel(LabelContent)
        case notice(NoticeViewModel)
        case lineItem(LineItemCellPresenting)
        case textField(TextFieldViewModel)
        case separator
        case interactableTextCell(InteractableTextViewModel)
    }

    public enum NavigationBarAppearance {
        case defaultDark
        case custom(leading: Screen.Style.LeadingButton, trailing: Screen.Style.TrailingButton, barStyle: Screen.Style.Bar)
    }
}
