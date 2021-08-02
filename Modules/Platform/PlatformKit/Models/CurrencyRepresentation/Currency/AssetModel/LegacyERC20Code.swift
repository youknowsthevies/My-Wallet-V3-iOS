// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An enumeration of coin codes that the App supports non-custodial.
public enum NonCustodialCoinCode: String, CaseIterable {
    case bitcoin = "BTC"
    case bitcoinCash = "BCH"
    case stellar = "XLM"
    case ethereum = "ETH"
}

/// An enumeration of the hardcoded already known ERC20 coins.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum LegacyERC20Code: String, CaseIterable {
    case aave = "AAVE"
    case pax = "PAX"
    case tether = "USDT"
    case wdgld = "WDGLD"
    case yearnFinance = "YFI"
}

/// An enumeration of the hardcoded new ERC20 coins.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum NewERC20Code: String, CaseIterable {
    case ogn = "OGN"
    case enj = "ENJ"
    case comp = "COMP"
    case link = "LINK"
    case tbtc = "TBTC"
    case wbtc = "WBTC"
    case snx = "SNX"
    case sushi = "SUSHI"
    case zrx = "ZRX"
    case usdc = "USDC"
    case uni = "UNI"
    case dai = "DAI"
    case bat = "BAT"
}

/// An enumeration of the hardcoded already known Custodial coins.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum LegacyCustodialCode: String, CaseIterable {
    case polkadot = "DOT"
    case algorand = "ALGO"
}

/// An enumeration of the hardcoded new Custodial coins.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum NewCustodialCode: String, CaseIterable {
    case bitClout = "CLOUT"
    case blockstack = "STX"
    case dogecoin = "DOGE"
    case eos = "EOS"
    case ethereumClassic = "ETC"
    case litecoin = "LTC"
    case mobileCoin = "MOB"
    case near = "NEAR"
    case tezos = "XTZ"
    case theta = "THETA"
}
