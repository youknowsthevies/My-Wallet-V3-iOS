// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum ClaimDomainFlow: AnalyticsEvent, Equatable {
        case searchDomainManual
        case searchDomainLoaded
        case domainSelected
        case domainTermsAgreed
        case domainCartEmptied
        case unstoppableSiteVisited
        case registerDomainStarted
        case registerDomainSucceeded
        case registerDomainFailed

        var type: AnalyticsEventType { .nabu }
    }
}

extension AnalyticsEventRecorderAPI {
    func record(event: AnalyticsEvents.New.ClaimDomainFlow) {
        record(event: event)
    }
}
