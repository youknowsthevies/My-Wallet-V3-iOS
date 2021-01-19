//
//  AvailablePairsClientAPI.swift
//  TransactionKit
//
//  Created by Alex McGregor on 10/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

protocol AvailablePairsClientAPI {
    var availableOrderPairs: Single<AvailableTradingPairsResponse> { get }
}
