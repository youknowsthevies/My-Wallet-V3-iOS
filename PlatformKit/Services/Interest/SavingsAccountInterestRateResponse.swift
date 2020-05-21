//
//  SavingsAccountInterestRateResponse.swift
//  PlatformKit
//
//  Created by Daniel Huri on 20/05/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public struct SavingsAccountInterestRateResponse: Decodable {
    public let currency: String
    public let rate: Double
}

