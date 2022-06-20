// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct Money: Codable, Equatable {

    public let value: String

    public let symbol: String

    public init(value: String, symbol: String) {
        self.value = value
        self.symbol = symbol
    }
}
