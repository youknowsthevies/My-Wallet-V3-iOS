// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import RxRelay

final class AnalyticsServiceMock: AnalyticsEventRecorderAPI {
    let recordRelay = PublishRelay<AnalyticsEvent>()
    func record(events: [AnalyticsEvent]) {}
    func record(event: AnalyticsEvent) {}
}
