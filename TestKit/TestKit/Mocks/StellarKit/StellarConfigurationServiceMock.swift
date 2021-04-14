//
//  StellarConfigurationServiceMock.swift
//  StellarKitTests
//
//  Created by Paulo on 03/12/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import StellarKit

class StellarConfigurationServiceMock: StellarConfigurationAPI {
    var configuration: Single<StellarConfiguration> = .just(StellarConfiguration.Stellar.test)
}
