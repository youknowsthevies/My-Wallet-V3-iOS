//
//  CGSize+Conveniences.swift
//  PlatformUIKit
//
//  Created by Daniel Huri on 22/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

extension CGSize {
    public init(edge: CGFloat) {
        self.init(width: edge, height: edge)
    }
}
