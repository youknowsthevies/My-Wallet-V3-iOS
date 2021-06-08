// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct CryptoCurrencyModel: Hashable {
    public enum Kind {
        case erc20(contract: String, logoPNGUrl: String)
        case coin
    }

    public let name: String
    public let code: String
    public let symbol: String
    public let maxDecimalPlaces: Int
    public let maxStartDate: TimeInterval
    public let kind: Kind

    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.code == rhs.code
    }
}

extension CryptoCurrencyModel {
    public static var aave: CryptoCurrencyModel {
        CryptoCurrencyModel(
            name: "Aave",
            code: "AAVE",
            symbol: "AAVE",
            maxDecimalPlaces: 18,
            maxStartDate: 1615831200,
            kind: .erc20(
                contract: "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9/logo.png"
            )
        )
    }
    public static var yearnFinance: CryptoCurrencyModel {
        CryptoCurrencyModel(
            name: "Yearn Finance",
            code: "YFI",
            symbol: "YFI",
            maxDecimalPlaces: 18,
            maxStartDate: 1615831200,
            kind: .erc20(
                contract: "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e/logo.png"
            )
        )
    }
    public static var wdgld: CryptoCurrencyModel {
        CryptoCurrencyModel(
            name: "Wrapped-DGLD",
            code: "WDGLD",
            symbol: "WDGLD",
            maxDecimalPlaces: 8,
            maxStartDate: 1605636000,
            kind: .erc20(
                contract: "0x123151402076fc819b7564510989e475c9cd93ca",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x123151402076fc819b7564510989e475c9cd93ca/logo.png"
            )
        )
    }
    public static var pax: CryptoCurrencyModel {
        CryptoCurrencyModel(
            name: "USD \(LocalizationConstants.digital)",
            code: "PAX",
            symbol: "PAX",
            maxDecimalPlaces: 18,
            maxStartDate: 1555060318,
            kind: .erc20(
                contract: "0x8E870D67F660D95d5be530380D0eC0bd388289E1",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x8E870D67F660D95d5be530380D0eC0bd388289E1/logo.png"
            )
        )
    }
    public static var tether: CryptoCurrencyModel {
        CryptoCurrencyModel(
            name: "Tether",
            code: "USDT",
            symbol: "USDT",
            maxDecimalPlaces: 6,
            maxStartDate: 1511829681,
            kind: .erc20(
                contract: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xdAC17F958D2ee523a2206206994597C13D831ec7/logo.png"
            )
        )
    }
}
