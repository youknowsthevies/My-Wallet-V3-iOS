//
//  SimpleBuySupportedPairsService.swift
//  PlatformKit
//
//  Created by Daniel Huri on 23/01/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import RxRelay

public final class SimpleBuySupportedPairsService: SimpleBuySupportedPairsServiceAPI {
    
    // MARK: - Injected
    
    private let client: SimpleBuySupportedPairsClientAPI
    
    // MARK: - Setup
    
    public init(client: SimpleBuySupportedPairsClientAPI) {
        self.client = client
    }
    
    // MARK: - SimpleBuySupportedPairsServiceAPI
    
    public func fetchPairs(for option: SupportedPairsFilterOption) -> Single<SimpleBuySupportedPairs> {
        client.supportedPairs(with: option)
            .map { SimpleBuySupportedPairs(response: $0, filterOption: option) }
    }
}
