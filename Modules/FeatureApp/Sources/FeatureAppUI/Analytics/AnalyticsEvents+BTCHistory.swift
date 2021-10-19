// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents {
    enum BTCHistoryEvent: AnalyticsEvent {
        case btcHistoryError(_ errorMessage: String)

        var name: String {
            "btc_history_error"
        }

        var params: [String: String]? {
            if case .btcHistoryError(let errorMessage) = self {
                return ["error": errorMessage]
            }
            return nil
        }
    }
}
