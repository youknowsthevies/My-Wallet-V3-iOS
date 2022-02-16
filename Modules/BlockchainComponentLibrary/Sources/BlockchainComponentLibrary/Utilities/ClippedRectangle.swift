// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CoreGraphics
import SwiftUI

struct ClippedRectangle: Shape {

    var x: CGFloat
    var y: CGFloat

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: .zero)
            path.addLine(to: CGPoint(x: rect.width * x, y: 0))
            path.addLine(to: CGPoint(x: rect.width * x, y: rect.height * y))
            path.addLine(to: CGPoint(x: 0, y: rect.height * y))
        }
    }
}
