// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents {
    enum New {
        enum Navigation: AnalyticsEvent {
            var type: AnalyticsEventType { .new }

            case signedIn
            case signedOut

            var name: String {
                switch self {
                case .signedIn:
                    return "Signed In"
                case .signedOut:
                    return "Signed Out"
                }
            }

            var params: [String : Any]? {
                [
                    "platform": "WALLET"
                ]
            }
        }
    }
}
