//
//  TextFormatterFactory.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

/// A factory for text formatters
public final class TextFormatterFactory {
        
    public static var alwaysCorrect: TextFormatting {
        AlwaysCorrectFormatter()
    }
    
    public static var cardNumber: TextFormatting {
        CardNumberFormatter()
    }
    
    public static var cardCVV: TextFormatting {
        CVVFormatter()
    }
    
    public static var cardExpirationDate: TextFormatting {
        CardExpirationDateFormatter()
    }
    
    public static var mobile: TextFormatting {
        MobileNumberTextFormatter()
    }
}
