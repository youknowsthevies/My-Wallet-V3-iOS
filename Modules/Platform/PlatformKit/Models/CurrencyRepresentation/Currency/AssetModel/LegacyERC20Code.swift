// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An enumeration of the previously known ERC20 coins.
/// This shall be removed once we fully support the new `AssetModel` architecture.
public enum LegacyERC20Code: String, CaseIterable {
    case aave = "AAVE"
    case pax = "PAX"
    case tether = "USDT"
    case wdgld = "WDGLD"
    case yearnFinance = "YFI"
}
