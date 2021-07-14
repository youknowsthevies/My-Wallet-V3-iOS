// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension CryptoCurrency {

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .bitcoin:
            return .bitcoin
        case .bitcoinCash:
            return .bitcoinCash
        case .ethereum:
            return .ethereum
        case .stellar:
            return .stellar
        case .other(let model):
            guard let spotColor = model.spotColor else {
                return .black
            }
            return UIColor(hex: spotColor) ?? .black
        case .erc20(let model):
            guard let spotColor = model.spotColor else {
                return .ethereum
            }
            return UIColor(hex: spotColor) ?? .ethereum
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        brandColor.withAlphaComponent(0.15)
    }

    // MARK: Logo Image `ImageResource`

    public var logoResource: ImageResource {
        switch self {
        case .bitcoin:
            return .local(name: "crypto-btc", bundle: .platformUIKit)
        case .bitcoinCash:
            return .local(name: "crypto-bch", bundle: .platformUIKit)
        case .ethereum:
            return .local(name: "crypto-eth", bundle: .platformUIKit)
        case .stellar:
            return .local(name: "crypto-xlm", bundle: .platformUIKit)
        case let .other(model):
            switch model.code {
            case LegacyCustodialCode.polkadot.rawValue:
                return .local(name: "crypto-dot", bundle: .platformUIKit)
            case LegacyCustodialCode.algorand.rawValue:
                return .local(name: "crypto-algo", bundle: .platformUIKit)
            default:
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
        case .erc20(let model):
            switch model.code {
            case LegacyERC20Code.aave.rawValue:
                return .local(name: "crypto-aave", bundle: .platformUIKit)
            case LegacyERC20Code.pax.rawValue:
                return .local(name: "crypto-usdd", bundle: .platformUIKit)
            case LegacyERC20Code.tether.rawValue:
                return .local(name: "crypto-usdt", bundle: .platformUIKit)
            case LegacyERC20Code.wdgld.rawValue:
                return .local(name: "crypto-wdgld", bundle: .platformUIKit)
            case LegacyERC20Code.yearnFinance.rawValue:
                return .local(name: "crypto-yfi", bundle: .platformUIKit)
            default:
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
        }
    }
}
