//
//  AlwaysCorrectFormatter.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 20/03/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public final class AlwaysCorrectFormatter: TextFormatting {
    public func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource {
        return .original(text: string)
    }
}
