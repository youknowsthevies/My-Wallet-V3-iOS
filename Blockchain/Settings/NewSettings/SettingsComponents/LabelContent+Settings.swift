//
//  LabelContent+Settings.swift
//  Blockchain
//
//  Created by Paulo on 01/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformUIKit

extension LabelContent.Value.Presentation.Content.Descriptors {

    /// Returns a descriptor for a settings cell
    static var settings: Descriptors {
        Descriptors(
            fontSize: 16,
            accessibilityIdSuffix: Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat
        )
    }
}
