//
//  AddCardCellPresenter.swift
//  Blockchain
//
//  Created by Alex McGregor on 3/24/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class AddCardCellPresenter {
    
    // MARK: - Localization
    
    private typealias LocalizationIDs = LocalizationConstants.Settings
    
    let descriptionLabelContent: LabelContent = .init(
        text: LocalizationIDs.addACard,
        font: .mainMedium(16.0),
        color: .textFieldText,
        alignment: .left,
        accessibility: .none
    )
    
    let badgeImageViewModel: BadgeImageViewModel = .primary(
        with: "Icon-Creditcard",
        cornerRadius: 14.0
    )
}
