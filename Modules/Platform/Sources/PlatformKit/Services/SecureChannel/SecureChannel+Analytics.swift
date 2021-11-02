// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    public enum SecureChannel: AnalyticsEvent, Equatable {
        case secureChannelErrorReceived(error: SecureChannelError)

        public var type: AnalyticsEventType { .nabu }

        public var params: [String: Any]? {
            switch self {
            case .secureChannelErrorReceived(let error):
                let errorIdentifier = String(describing: error)
                return ["error": errorIdentifier]
            }
        }
    }
}

extension AnalyticsEventRecorderAPI {
    /// Helper method to record `SecureChannel` events
    /// - Parameter event: A `SecureChannel` event to be tracked
    public func record(event: AnalyticsEvents.New.SecureChannel) {
        record(event: event)
    }
}
