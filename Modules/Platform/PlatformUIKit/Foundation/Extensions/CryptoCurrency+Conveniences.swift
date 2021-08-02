// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension CryptoCurrency {

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .coin(let model):
            guard let spotColor = model.spotColor else {
                return .black
            }
            return UIColor(hex: spotColor) ?? .black
        case .erc20(let model):
            guard let spotColor = model.spotColor else {
                return CryptoCurrency.coin(.ethereum).brandColor
            }
            return UIColor(hex: spotColor) ?? .black
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        brandColor.withAlphaComponent(0.15)
    }

    // MARK: Logo Image `ImageResource`

    public var logoResource: ImageResource {
        switch self {
        case .coin(let model):
            switch model.code {
            case NonCustodialCoinCode.bitcoin.rawValue:
                return .local(name: "crypto-btc", bundle: .platformUIKit)
            case NonCustodialCoinCode.bitcoinCash.rawValue:
                return .local(name: "crypto-bch", bundle: .platformUIKit)
            case NonCustodialCoinCode.ethereum.rawValue:
                return .local(name: "crypto-eth", bundle: .platformUIKit)
            case NonCustodialCoinCode.stellar.rawValue:
                return .local(name: "crypto-xlm", bundle: .platformUIKit)
            case LegacyCustodialCode.polkadot.rawValue:
                return .local(name: "crypto-dot", bundle: .platformUIKit)
            case LegacyCustodialCode.algorand.rawValue:
                return .local(name: "crypto-algo", bundle: .platformUIKit)
            case NewCustodialCode.bitClout.rawValue:
                return .local(name: "crypto-clout", bundle: .platformUIKit)
            case NewCustodialCode.blockstack.rawValue:
                return .local(name: "crypto-stx", bundle: .platformUIKit)
            case NewCustodialCode.dogecoin.rawValue:
                return .local(name: "crypto-doge", bundle: .platformUIKit)
            case NewCustodialCode.eos.rawValue:
                return .local(name: "crypto-eos", bundle: .platformUIKit)
            case NewCustodialCode.ethereumClassic.rawValue:
                return .local(name: "crypto-etc", bundle: .platformUIKit)
            case NewCustodialCode.litecoin.rawValue:
                return .local(name: "crypto-ltc", bundle: .platformUIKit)
            case NewCustodialCode.mobileCoin.rawValue:
                return .local(name: "crypto-mobi", bundle: .platformUIKit)
            case NewCustodialCode.near.rawValue:
                return .local(name: "crypto-near", bundle: .platformUIKit)
            case NewCustodialCode.tezos.rawValue:
                return .local(name: "crypto-xtz", bundle: .platformUIKit)
            case NewCustodialCode.theta.rawValue:
                return .local(name: "crypto-theta", bundle: .platformUIKit)
            default:
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
        case .erc20(let model):
            switch model.code {
            case LegacyERC20Code.aave.rawValue:
                return .local(name: "crypto-aave", bundle: .platformUIKit)
            case LegacyERC20Code.pax.rawValue:
                return .local(name: "crypto-pax", bundle: .platformUIKit)
            case LegacyERC20Code.tether.rawValue:
                return .local(name: "crypto-usdt", bundle: .platformUIKit)
            case LegacyERC20Code.wdgld.rawValue:
                return .local(name: "crypto-wdgld", bundle: .platformUIKit)
            case LegacyERC20Code.yearnFinance.rawValue:
                return .local(name: "crypto-yfi", bundle: .platformUIKit)
            case NewERC20Code.bat.rawValue:
                return .local(name: "crypto-bat", bundle: .platformUIKit)
            case NewERC20Code.comp.rawValue:
                return .local(name: "crypto-comp", bundle: .platformUIKit)
            case NewERC20Code.dai.rawValue:
                return .local(name: "crypto-dai", bundle: .platformUIKit)
            case NewERC20Code.enj.rawValue:
                return .local(name: "crypto-enj", bundle: .platformUIKit)
            case NewERC20Code.link.rawValue:
                return .local(name: "crypto-link", bundle: .platformUIKit)
            case NewERC20Code.ogn.rawValue:
                return .local(name: "crypto-ogn", bundle: .platformUIKit)
            case NewERC20Code.snx.rawValue:
                return .local(name: "crypto-snx", bundle: .platformUIKit)
            case NewERC20Code.sushi.rawValue:
                return .local(name: "crypto-sushi", bundle: .platformUIKit)
            case NewERC20Code.tbtc.rawValue:
                return .local(name: "crypto-tbtc", bundle: .platformUIKit)
            case NewERC20Code.uni.rawValue:
                return .local(name: "crypto-uni", bundle: .platformUIKit)
            case NewERC20Code.usdc.rawValue:
                return .local(name: "crypto-usdc", bundle: .platformUIKit)
            case NewERC20Code.wbtc.rawValue:
                return .local(name: "crypto-wbtc", bundle: .platformUIKit)
            case NewERC20Code.zrx.rawValue:
                return .local(name: "crypto-zrx", bundle: .platformUIKit)
            default:
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
        }
    }
}
