// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AnalyticsEventRecorderAPI: AnyObject {
    func record(event: AnalyticsEvent)
    func record(events: [AnalyticsEvent])
}

public extension AnalyticsEventRecorderAPI {
    func record(events: [AnalyticsEvent]) {
        events.forEach {
            record(event: $0)
        }
    }
}
