// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class AnalyticsEventRecorder: AnalyticsEventRecorderAPI {

    // MARK: - Properties

    private let analyticsServiceProviders: [AnalyticsServiceProviderAPI]

    // MARK: - Setup

    public init(analyticsServiceProviders: [AnalyticsServiceProviderAPI]) {
        self.analyticsServiceProviders = analyticsServiceProviders
    }

    public func record(event: AnalyticsEvent) {
        for provider in analyticsServiceProviders where provider.isEventSupported(event) {
            provider.trackEvent(title: event.name, parameters: event.params)
            #if DEBUG
            print("📡", event.name, terminator: " ")
            if let parameters = event.params {
                print("parameters:")
                for parameter in parameters {
                    print("\t", parameter.key, "=", parameter.value)
                }
            }
            print()
            #endif
        }
    }
}
