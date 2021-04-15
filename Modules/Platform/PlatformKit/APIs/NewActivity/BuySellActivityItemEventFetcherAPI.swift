//
//  BuySellActivityItemEventFetcherAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol BuySellActivityItemEventFetcherAPI {
    var buySellActivity: Single<[BuySellActivityItemEvent]> { get }
}
