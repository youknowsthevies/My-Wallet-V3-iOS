// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Series: Hashable {
    public let window: Interval
    public let scale: Scale
}

extension Series {
    public static let now = Self(window: ._15_minutes, scale: ._15_minutes)
    public static let day = Self(window: .day, scale: ._15_minutes)
    public static let week = Self(window: .week, scale: ._1_hour)
    public static let month = Self(window: .month, scale: ._2_hours)
    public static let year = Self(window: .year, scale: ._1_day)
    public static let all = Self(window: .all, scale: ._5_days)
}
