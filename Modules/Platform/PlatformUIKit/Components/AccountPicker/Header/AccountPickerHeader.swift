//
//  AccountPickerHeader.swift
//  PlatformUIKit
//
//  Created by Paulo on 14/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// The type of Header the screen should show
public enum AccountPickerHeaderType {
    /// No header will be shown
    case none
    /// A simple Title + Subtitle header
    case simple(AccountPickerSimpleHeaderModel)
    /// The default header containing a pattern background.
    case `default`(AccountPickerHeaderModel)
}
