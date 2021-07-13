// Copyright © Blockchain Luxembourg S.A. All rights reserved.

#if DEBUG
import RxRelay
import RxSwift

/// An empty implementation of `AnalyticsEventRecorderAPI` to support Unit Tests, SwiftUI previews, etc.
public final class NoOpAnalyticsRecorder: AnalyticsEventRecorderAPI {

    public let recordRelay: PublishRelay<AnalyticsEvent> = .init()

    public init() {}

    public func record(event: AnalyticsEvent) {
        // no-op
    }
}
#endif
