//
//  MobileNumberTextFormatter.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PhoneNumberKit

/// Formats user mobile number entry to be formatted correctly.
final class MobileNumberTextFormatter: TextFormatting {
    
    private let formatter = PartialFormatter()
    
    func format(text: String) -> TextFormatType {
        let formatted = formatter.formatPartial(text)
        return formatted == text ? .keepExisting(text) : .changed(new: formatted)
    }
}
