//
//  TextFormatting.swift
//  PlatformUIKit
//
//  Created by AlexM on 2/10/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public enum TextFormatType {
    case changed(new: String)
    case keepExisting(String)
    
    var text: String {
        switch self {
        case .changed(new: let new):
            return new
        case .keepExisting(let text):
            return text
        }
    }
}

public protocol TextFormatting: class {
    func format(text: String) -> TextFormatType
}

public final class EmptyFormatter: TextFormatting {
    public func format(text: String) -> TextFormatType {
        return .keepExisting(text)
    }
}
