//
//  BuyActivityItemEventFetcherAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 6/5/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxRelay
import RxSwift

public protocol BuyActivityItemEventFetcherAPI {
    var buyActivity: Single<[BuyActivityItemEvent]> { get }
}
