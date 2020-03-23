//
//  TextFormatterFactory.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// A factory for text formatters
public final class TextFormatterFactory {
        
    public static var empty: TextFormatting {
        return EmptyFormatter()
    }
    
    public static var mobile: TextFormatting {
        return MobileNumberTextFormatter()
    }
}
