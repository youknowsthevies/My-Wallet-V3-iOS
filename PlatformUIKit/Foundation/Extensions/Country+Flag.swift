//
//  Country+Flag.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 02/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension Country {
    
    // MARK: - Flag (As Emoji Unicode Representation)
    public var flag: String {
        let base : UInt32 = 127397
        var emoji = ""
        for v in code.unicodeScalars {
            guard let scalar = UnicodeScalar(base + v.value) else { return "" }
            emoji.unicodeScalars.append(scalar)
        }
        return emoji
    }
}
