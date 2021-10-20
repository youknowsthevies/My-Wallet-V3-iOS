// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreGraphics

extension CGSize {

    public var min: CGFloat { Swift.min(width, height) }
    public var max: CGFloat { Swift.max(width, height) }
}

extension CGSize {

    public init(length: CGFloat) {
        self.init(width: length, height: length)
    }
}
