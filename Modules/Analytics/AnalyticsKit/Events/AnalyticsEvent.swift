// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AnalyticsEvent {
    var timestamp: Date? { get }
    var name: String { get }
    var params: [String: Any]? { get }
    var type: AnalyticsEventType { get }
}

public extension AnalyticsEvent {
    var type: AnalyticsEventType {
        .old
    }

    var timestamp: Date? {
        nil
    }

    var params: [String: Any]? {
        nil
    }
}
