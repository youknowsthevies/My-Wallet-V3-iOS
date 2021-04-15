//
//  KYCPageError.swift
//  Blockchain
//
//  Created by Chris Arriola on 8/21/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

enum KYCPageError {
    case countryNotSupported(CountryData)
    case stateNotSupported(KYCState)
}
