//
//  SimpleBuySupportedPairsServiceAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuySupportedPairsServiceAPI: class {

    /// Fetches `pairs` using the specified filter
    func fetchPairs(for option: SupportedPairsFilterOption) -> Single<SimpleBuySupportedPairs>
}
