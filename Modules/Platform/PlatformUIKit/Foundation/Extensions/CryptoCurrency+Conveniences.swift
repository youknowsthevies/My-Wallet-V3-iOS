// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension CryptoCurrency {

    /// Initialize with a display currency code: `BTC`, `ETH`, `BCH`, `XLM`, `USD-D`, `ALGO`, `USD-T`
    public init?(displayCode: String) {
        self.init(code: displayCode)
    }

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .algorand:
            return .algorand
        case .bitcoin:
            return .bitcoin
        case .bitcoinCash:
            return .bitcoinCash
        case .ethereum:
            return .ethereum
        case .polkadot:
            return .polkadot
        case .stellar:
            return .stellar
        case .erc20(.aave):
            return .aave
        case .erc20(.pax):
            return .usdd
        case .erc20(.tether):
            return .tether
        case .erc20(.wdgld):
            return .black
        case .erc20(.yearnFinance):
            return .yearnFinance
        case .erc20:
            // TODO: (paulo)
            return .blue
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        switch self {
        case .erc20(.wdgld):
            return UIColor.wdgld.withAlphaComponent(0.15)
        default:
            return brandColor.withAlphaComponent(0.15)
        }
    }

    // MARK: Logo Image `ImageResource`

    public var logoResource: ImageResource {
        switch self {
        case .algorand:
            return .local(name: "filled_algo_large", bundle: .platformUIKit)
        case .bitcoin:
            return .local(name: "filled_btc_large", bundle: .platformUIKit)
        case .bitcoinCash:
            return .local(name: "filled_bch_large", bundle: .platformUIKit)
        case .ethereum:
            return .local(name: "filled_eth_large", bundle: .platformUIKit)
        case .polkadot:
            return .local(name: "filled_dot_large", bundle: .platformUIKit)
        case .stellar:
            return .local(name: "filled_xlm_large", bundle: .platformUIKit)
        case .erc20(.aave):
            return .local(name: "filled_aave_large", bundle: .platformUIKit)
        case .erc20(.pax):
            return .local(name: "filled_pax_large", bundle: .platformUIKit)
        case .erc20(.tether):
            return .local(name: "filled_usdt_large", bundle: .platformUIKit)
        case .erc20(.wdgld):
            return .local(name: "filled_wdgld_large", bundle: .platformUIKit)
        case .erc20(.yearnFinance):
            return .local(name: "filled_yfi_large", bundle: .platformUIKit)
        case .erc20:
            fatalError("Unsupported, to add remote case.")
        }
    }
}
