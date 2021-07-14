// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation
import RxSwift

public extension PrimitiveSequence where Trait == SingleTrait {

    /// Records analytics event using a given recorder on success
    func recordOnSuccess(analyticsEvent: AnalyticsEvent,
                         using recorder: AnalyticsEventRecorderAPI) -> Single<Element> {
        self.do(onSuccess: { _ in
            recorder.record(event: analyticsEvent)
        })
    }

    /// Records analytics event using a given recorder on error
    func recordOnError(analyticsEvent: AnalyticsEvent,
                       using recorder: AnalyticsEventRecorderAPI) -> Single<Element> {
        self.do(onError: { _ in
              recorder.record(event: analyticsEvent)
        })
    }

    /// Records analytics event using a given recorder on any `Single` result
    func recordOnResult(successEvent: AnalyticsEvent,
                        errorEvent: AnalyticsEvent,
                        using recorder: AnalyticsEventRecorderAPI) -> Single<Element> {
        self.do(
            onSuccess: { _ in
                recorder.record(event: successEvent)
            },
            onError: { _ in
              recorder.record(event: errorEvent)
            }
        )
    }

    /// Records analytics event using a given recorder on any `Single` lifecycle
    func record(subscribeEvent: AnalyticsEvent,
                successEvent: AnalyticsEvent,
                errorEvent: AnalyticsEvent,
                using recorder: AnalyticsEventRecorderAPI) -> Single<Element> {
        self.do(
            onSuccess: { _ in
                recorder.record(event: successEvent)
            },
            onError: { _ in
                recorder.record(event: errorEvent)
            },
            onSubscribe: {
                recorder.record(event: subscribeEvent)
            }
        )
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
public extension ObservableType {

    /// Records analytics event using a given recorder
    func record(analyticsEvent: AnalyticsEvent,
                using recorder: AnalyticsEventRecorderAPI) -> Observable<Element> {
        self.do(onNext: { _ in
            recorder.record(event: analyticsEvent)
        })
    }
}
