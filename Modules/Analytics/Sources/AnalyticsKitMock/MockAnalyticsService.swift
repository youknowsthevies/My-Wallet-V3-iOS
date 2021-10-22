// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

public class MockAnalyticsService: AnalyticsServiceProviderAPI {

    public var supportedEventTypes = [AnalyticsEventType.firebase]

    public init() {}

    public func trackEvent(title: String, parameters: [String: Any]?) {}
}

public class MockAnalyticsRecorder: AnalyticsEventRecorderAPI {

    public private(set) var recordEventCalled: (called: Bool, event: AnalyticsEvent?) = (false, nil)
    public private(set) var recordEventsCalled: (called: Bool, events: [AnalyticsEvent]?) = (false, nil)

    public init() {}

    public func trackEvent(title: String, parameters: [String: Any]?) {}

    public func record(event: AnalyticsEvent) {
        recordEventCalled = (true, event)
    }

    public func record(events: [AnalyticsEvent]) {
        recordEventsCalled = (true, events)
    }
}
