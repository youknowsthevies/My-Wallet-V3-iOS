//
//  KYCPageModel.swift
//  Blockchain
//
//  Created by Alex McGregor on 8/13/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public enum KYCPageModel {
    case email(NabuUser)
    case personalDetails(NabuUser)
    case address(NabuUser, CountryData?, [KYCState])
    case phone(NabuUser)
    case verifyIdentity(countryCode: String)
}
