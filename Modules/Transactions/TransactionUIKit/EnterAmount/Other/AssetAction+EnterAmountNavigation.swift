//
//  AssetAction+EnterAmountNavigation.swift
//  TransactionUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 06/04/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

extension AssetAction {
    var allowsBackButton: Bool {
        switch self {
        case .send,
             .deposit,
             .receive,
             .sell,
             .swap,
             .withdraw,
             .viewActivity:
            return true
        }
    }
}
