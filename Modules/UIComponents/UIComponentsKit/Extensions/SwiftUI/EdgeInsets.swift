// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SwiftUI

extension EdgeInsets {
    public static var zero: EdgeInsets { .init() }
}

extension EdgeInsets {

    public static func + (lhs: EdgeInsets, rhs: EdgeInsets) -> EdgeInsets { apply(lhs, rhs)(+) }
    public static func - (lhs: EdgeInsets, rhs: EdgeInsets) -> EdgeInsets { apply(lhs, rhs)(-) }
    public static func / (lhs: EdgeInsets, rhs: EdgeInsets) -> EdgeInsets { apply(lhs, rhs)(/) }
    public static func * (lhs: EdgeInsets, rhs: EdgeInsets) -> EdgeInsets { apply(lhs, rhs)(*) }

    public static func + (lhs: EdgeInsets, rhs: CGFloat) -> EdgeInsets { apply(lhs, rhs)(+) }
    public static func - (lhs: EdgeInsets, rhs: CGFloat) -> EdgeInsets { apply(lhs, rhs)(-) }
    public static func / (lhs: EdgeInsets, rhs: CGFloat) -> EdgeInsets { apply(lhs, rhs)(/) }
    public static func * (lhs: EdgeInsets, rhs: CGFloat) -> EdgeInsets { apply(lhs, rhs)(*) }

    public static func + (lhs: CGFloat, rhs: EdgeInsets) -> EdgeInsets { apply(rhs, lhs)(+) }
    public static func - (lhs: CGFloat, rhs: EdgeInsets) -> EdgeInsets { apply(rhs, lhs)(-) }
    public static func / (lhs: CGFloat, rhs: EdgeInsets) -> EdgeInsets { apply(rhs, lhs)(/) }
    public static func * (lhs: CGFloat, rhs: EdgeInsets) -> EdgeInsets { apply(rhs, lhs)(*) }

    private static func apply(
        _ lhs: EdgeInsets,
        _ rhs: EdgeInsets
    ) -> (_ operator: (CGFloat, CGFloat) -> CGFloat) -> EdgeInsets {
        {
            .init(
                top: $0(lhs.top, rhs.top),
                leading: $0(lhs.leading, rhs.leading),
                bottom: $0(lhs.bottom, rhs.bottom),
                trailing: $0(lhs.trailing, rhs.trailing)
            )
        }
    }

    private static func apply(
        _ lhs: EdgeInsets,
        _ rhs: CGFloat
    ) -> (_ operator: (CGFloat, CGFloat) -> CGFloat) -> EdgeInsets {
        {
            .init(
                top: $0(lhs.top, rhs),
                leading: $0(lhs.leading, rhs),
                bottom: $0(lhs.bottom, rhs),
                trailing: $0(lhs.trailing, rhs)
            )
        }
    }
}
