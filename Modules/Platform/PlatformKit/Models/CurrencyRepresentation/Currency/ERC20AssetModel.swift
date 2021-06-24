// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct ERC20AssetModel: CryptoAssetModel {
    public static let typeTag: AnyHashable = "ETH.ERC20"
    public let name: String
    public let code: String
    public let maxDecimalPlaces: Int
    public let maxStartDate: TimeInterval
    public let kind: CryptoAssetType
    public var cryptoCurrency: CryptoCurrency { .erc20(self) }
    /// A `Hashable` tag that can be used to discern between different L1/L2 chains.
    public var typeTag: AnyHashable { ERC20AssetModel.typeTag }

    init(name: String, code: String, maxDecimalPlaces: Int, maxStartDate: TimeInterval, kind: CryptoAssetType) {
        guard case .erc20 = kind else {
            preconditionFailure("Creating a ERC20AssetModel with a non 'erc20' kind is a programmatic error")
        }
        self.name = name
        self.code = code
        self.maxDecimalPlaces = maxDecimalPlaces
        self.maxStartDate = maxStartDate
        self.kind = kind
    }
}

extension ERC20AssetModel {
    public static var aave: ERC20AssetModel {
        ERC20AssetModel(
            name: "Aave",
            code: "AAVE",
            maxDecimalPlaces: 18,
            maxStartDate: 1615831200,
            kind: .erc20(
                contract: "0x7fc66500c84a76ad7e9c93437bfc5ac33e2ddae9",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9/logo.png"
            )
        )
    }
    public static var yearnFinance: ERC20AssetModel {
        ERC20AssetModel(
            name: "Yearn Finance",
            code: "YFI",
            maxDecimalPlaces: 18,
            maxStartDate: 1615831200,
            kind: .erc20(
                contract: "0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x0bc529c00C6401aEF6D220BE8C6Ea1667F6Ad93e/logo.png"
            )
        )
    }
    public static var wdgld: ERC20AssetModel {
        ERC20AssetModel(
            name: "Wrapped-DGLD",
            code: "WDGLD",
            maxDecimalPlaces: 8,
            maxStartDate: 1605636000,
            kind: .erc20(
                contract: "0x123151402076fc819b7564510989e475c9cd93ca",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x123151402076fc819b7564510989e475c9cd93ca/logo.png"
            )
        )
    }
    public static var pax: ERC20AssetModel {
        ERC20AssetModel(
            name: "USD \(LocalizationConstants.digital)",
            code: "PAX",
            maxDecimalPlaces: 18,
            maxStartDate: 1555060318,
            kind: .erc20(
                contract: "0x8E870D67F660D95d5be530380D0eC0bd388289E1",
                // swiftlint:disable:next line_length
                logoPNGUrl: "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0x8E870D67F660D95d5be530380D0eC0bd388289E1/logo.png"
            )
        )
    }
    public static var tether: ERC20AssetModel {
        ERC20AssetModel(
            name: "Tether",
            code: "USDT",
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
