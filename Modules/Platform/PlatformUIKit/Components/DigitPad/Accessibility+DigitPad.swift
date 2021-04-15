//
//  Accessibility+DigitPad.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 21/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension Accessibility.Identifier {
    struct DigitPad {
        private static let prefix = "DigitPad."
        static let digitButtonFormat = "\(prefix)digit-"
        static let faceIdButton = "\(prefix)faceIdButton"
        static let touchIdButton = "\(prefix)touchIdButton"
        static let backspaceButton = "\(prefix)backspaceButton"
    }
}
