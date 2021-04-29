//
//  AnalyticsEvents+AppCoordinator.swift
//  Blockchain
//
//  Created by Maciej Burda on 21/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import AnalyticsKit
import Foundation

extension AnalyticsEvents {
    enum AppCoordinatorEvent: AnalyticsEvent {
        case btcHistoryError(_ errorMessage: String)
        
        var name: String {
            "btc_history_error"
        }
        
        var params: [String : String]? {
            if case let .btcHistoryError(errorMessage) = self {
                return ["error": errorMessage]
            }
            return nil
        }
    }
}
