// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay

public protocol AnalyticsEventRelayRecording {
    var recordRelay: PublishRelay<AnalyticsEvent> { get }
}

public protocol AnalyticsEventRecording: class {
    func record(event: AnalyticsEvent)
}
