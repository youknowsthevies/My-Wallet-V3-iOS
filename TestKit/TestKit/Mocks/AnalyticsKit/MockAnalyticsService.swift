// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

class MockAnalyticsService: AnalyticsServiceProviding {
    func trackEvent(title: String, parameters: [String: Any]?) { }
}
