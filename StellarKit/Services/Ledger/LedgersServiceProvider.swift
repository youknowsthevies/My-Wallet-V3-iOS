//
//  LedgersServiceProvider.swift
//  StellarKit
//
//  Created by Paulo on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import RxSwift
import stellarsdk

protocol LedgersServiceProviderAPI: AnyObject {
    var ledgersService: Single<LedgersServiceAPI> { get }
}

final class LedgersServiceProvider: LedgersServiceProviderAPI {

    private let configurationService: StellarConfigurationAPI
    
    public init(configurationService: StellarConfigurationAPI = resolve()) {
        self.configurationService = configurationService
    }

    var ledgersService: Single<LedgersServiceAPI> {
        configurationService
            .configuration
            .map { configuration -> LedgersServiceAPI in
                configuration.sdk.ledgers
            }
    }
}
