// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Series: Hashable {
    public let window: Interval
    public let scale: Interval
}

extension Series {
    public static let _15_minutes = Self(window: ._15_minutes, scale: ._15_minutes)
    public static let day = Self(window: .day, scale: ._15_minutes)
    public static let week = Self(window: .week, scale: .hour)
    public static let month = Self(window: .month, scale: ._2_hours)
    public static let year = Self(window: .year, scale: .day)
    public static let all = Self(window: .all, scale: .weekdays)
}
