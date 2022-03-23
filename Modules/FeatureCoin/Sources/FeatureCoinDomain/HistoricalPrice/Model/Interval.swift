// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Interval: Hashable {
    public let value: Int
    public let component: Calendar.Component
}

extension Interval {
    public static let _15_minutes = Self(value: 15, component: .minute)
    public static let day = Self(value: 1, component: .day)
    public static let week = Self(value: 1, component: .weekOfMonth)
    public static let month = Self(value: 1, component: .month)
    public static let year = Self(value: 1, component: .year)
    public static let all = Self(value: 20, component: .year)
}

public struct Scale: Hashable {
    public let value: TimeInterval
}

extension Scale {
    public static let _15_minutes = Self(value: 900)
    public static let _1_hour = Self(value: 3600)
    public static let _2_hours = Self(value: 7200)
    public static let _1_day = Self(value: 86400)
    public static let _5_days = Self(value: 432000)
}
