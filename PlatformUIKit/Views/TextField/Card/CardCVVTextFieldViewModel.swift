//
//  CardCVVTextFieldViewModel.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import ToolKit

public final class CardCVVTextFieldViewModel: TextFieldViewModel {
            
    // MARK: - Setup
    
    public init(validator: TextValidating,
                matchValidator: CVVToCreditCardMatchValidator,
                messageRecorder: MessageRecording) {
        super.init(
            with: .cardCVV,
            validator: validator,
            formatter: TextFormatterFactory.cardCVV,
            textMatcher: matchValidator,
            messageRecorder: messageRecorder
        )
    }
}
