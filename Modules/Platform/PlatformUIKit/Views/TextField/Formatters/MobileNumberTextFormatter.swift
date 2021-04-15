//
//  MobileNumberTextFormatter.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PhoneNumberKit
import RxSwift

/// Formats user mobile number entry to be formatted correctly.
final class MobileNumberTextFormatter: TextFormatting {
    
    private let formatter = PartialFormatter()
    
    func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource {
        let processedString = formatter.formatPartial(string)
        return processedString == string ? .original(text: string) : .formatted(to: processedString)
    }
}
