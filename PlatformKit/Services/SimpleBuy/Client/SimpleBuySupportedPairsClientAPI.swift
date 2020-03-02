//
//  SimpleBuySupportedPairsClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

/// Fetches the supported pairs
public protocol SimpleBuySupportedPairsClientAPI: class {
    /// Fetch the supported pairs according to a given fetch-option
    func supportedPairs(with option: SupportedPairsFilterOption) -> Single<SimpleBuySupportedPairsResponse>
}
