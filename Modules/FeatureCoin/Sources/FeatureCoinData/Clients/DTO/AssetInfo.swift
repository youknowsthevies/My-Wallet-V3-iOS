// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import MoneyKit

public struct AssetInfo: Decodable {

    public let currencyInfo: CurrencyInfo
    public let description: String?
    public let whitepaper: String?
    public let website: String?
    public let language: String?
}

extension AssetInfo {

    public struct CurrencyInfo: Decodable {

        public let symbol: String
        public let displaySymbol: String
        public let name: String
        public let type: CurrencyInfoType
        public let precision: Int
        public let products: [String]
    }
}

extension AssetInfo.CurrencyInfo {

    public struct CurrencyInfoType: Decodable {

        public let name: String
        public let logoPngUrl: String?
    }
}
