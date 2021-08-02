// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension CryptoCurrency {

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .coin(let model):
            if let match = CustodialCoinCode.allCases.first(where: { $0.rawValue == model.code }) {
                return UIColor(hex: match.spotColor) ?? .black
            }
            return model.spotColor.flatMap(UIColor.init(hex:)) ?? .black
        case .erc20(let model):
            if let match = ERC20Code.allCases.first(where: { $0.rawValue == model.code }) {
                return UIColor(hex: match.spotColor) ?? .black
            }
            return model.spotColor.flatMap(UIColor.init(hex:)) ?? UIColor(hex: "473BCB")!
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
            case CustodialCoinCode.polkadot.rawValue:
                return .local(name: "crypto-dot", bundle: .platformUIKit)
            case CustodialCoinCode.algorand.rawValue:
                return .local(name: "crypto-algo", bundle: .platformUIKit)
            case CustodialCoinCode.bitClout.rawValue:
                return .local(name: "crypto-clout", bundle: .platformUIKit)
            case CustodialCoinCode.blockstack.rawValue:
                return .local(name: "crypto-stx", bundle: .platformUIKit)
            case CustodialCoinCode.dogecoin.rawValue:
                return .local(name: "crypto-doge", bundle: .platformUIKit)
            case CustodialCoinCode.eos.rawValue:
                return .local(name: "crypto-eos", bundle: .platformUIKit)
            case CustodialCoinCode.ethereumClassic.rawValue:
                return .local(name: "crypto-etc", bundle: .platformUIKit)
            case CustodialCoinCode.litecoin.rawValue:
                return .local(name: "crypto-ltc", bundle: .platformUIKit)
            case CustodialCoinCode.mobileCoin.rawValue:
                return .local(name: "crypto-mobi", bundle: .platformUIKit)
            case CustodialCoinCode.near.rawValue:
                return .local(name: "crypto-near", bundle: .platformUIKit)
            case CustodialCoinCode.tezos.rawValue:
                return .local(name: "crypto-xtz", bundle: .platformUIKit)
            case CustodialCoinCode.theta.rawValue:
                return .local(name: "crypto-theta", bundle: .platformUIKit)
            default:
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
        case .erc20(let model):
            switch model.code {
            case ERC20Code.aave.rawValue:
                return .local(name: "crypto-aave", bundle: .platformUIKit)
            case ERC20Code.pax.rawValue:
                return .local(name: "crypto-pax", bundle: .platformUIKit)
            case ERC20Code.tether.rawValue:
                return .local(name: "crypto-usdt", bundle: .platformUIKit)
            case ERC20Code.wdgld.rawValue:
                return .local(name: "crypto-wdgld", bundle: .platformUIKit)
            case ERC20Code.yearnFinance.rawValue:
                return .local(name: "crypto-yfi", bundle: .platformUIKit)
            case ERC20Code.bat.rawValue:
                return .local(name: "crypto-bat", bundle: .platformUIKit)
            case ERC20Code.comp.rawValue:
                return .local(name: "crypto-comp", bundle: .platformUIKit)
            case ERC20Code.dai.rawValue:
                return .local(name: "crypto-dai", bundle: .platformUIKit)
            case ERC20Code.enj.rawValue:
                return .local(name: "crypto-enj", bundle: .platformUIKit)
            case ERC20Code.link.rawValue:
                return .local(name: "crypto-link", bundle: .platformUIKit)
            case ERC20Code.ogn.rawValue:
                return .local(name: "crypto-ogn", bundle: .platformUIKit)
            case ERC20Code.snx.rawValue:
                return .local(name: "crypto-snx", bundle: .platformUIKit)
            case ERC20Code.sushi.rawValue:
                return .local(name: "crypto-sushi", bundle: .platformUIKit)
            case ERC20Code.tbtc.rawValue:
                return .local(name: "crypto-tbtc", bundle: .platformUIKit)
            case ERC20Code.uni.rawValue:
                return .local(name: "crypto-uni", bundle: .platformUIKit)
            case ERC20Code.usdc.rawValue:
                return .local(name: "crypto-usdc", bundle: .platformUIKit)
            case ERC20Code.wbtc.rawValue:
                return .local(name: "crypto-wbtc", bundle: .platformUIKit)
            case ERC20Code.zrx.rawValue:
                return .local(name: "crypto-zrx", bundle: .platformUIKit)
            default:
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
        }
    }
}
