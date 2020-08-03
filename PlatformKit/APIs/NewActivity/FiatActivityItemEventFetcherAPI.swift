//
//  FiatActivityItemEventFetcherAPI.swift
//  PlatformKit
//
//  Created by Alex McGregor on 7/31/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol FiatActivityItemEventFetcherAPI: class {
    func fiatActivity(fiatCurrency: FiatCurrency) -> Single<[FiatActivityItemEvent]>
}
