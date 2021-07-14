// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import RxCocoa

class MockAnalyticsService: AnalyticsServiceProviderAPI {
    var supportedEventTypes = [AnalyticsEventType.firebase]

    func trackEvent(title: String, parameters: [String: Any]?) { }
}

class MockAnalyticsRecorder: AnalyticsEventRecorderAPI {
    var recordRelay = PublishRelay<AnalyticsEvent>()

    func trackEvent(title: String, parameters: [String: Any]?) { }

    var recordEventCalled: (called: Bool, event: AnalyticsEvent?) = (false, nil)
    func record(event: AnalyticsEvent) {
        recordEventCalled = (true, event)
    }

    var recordEventsCalled: (called: Bool, events: [AnalyticsEvent]?) = (false, nil)
    func record(events: [AnalyticsEvent]) {
        recordEventsCalled = (true, events)
    }
}
