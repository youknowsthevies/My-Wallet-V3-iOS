//
//  UIButton+Touches.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension UIButton {
    public func addTargetForTouchDown(_ target: Any?, selector: Selector) {
        addTarget(target, action: selector, for: .touchDown)
    }
    
    public func addTargetForTouchUp(_ target: Any?, selector: Selector) {
        addTarget(target, action: selector, for: [.touchCancel, .touchUpInside, .touchUpOutside])
    }
}
