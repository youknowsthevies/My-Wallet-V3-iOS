// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct SavingsAccountInterestRateResponse: Decodable {
    public let currency: String
    public let rate: Double
}

