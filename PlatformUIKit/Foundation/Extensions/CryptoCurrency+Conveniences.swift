//
//  CryptoCurrency+Conveniences.swift
//  PlatformUIKit
//
//  Created by AlexM on 10/28/19.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import PlatformKit

extension CryptoCurrency {

    /// Initialize with a display currency code: `BTC`, `ETH`, `BCH`, `XLM`, `USD-D`, `ALGO`
    public init?(displayCode: String) {
        guard let currency = (CryptoCurrency.allCases.first { $0.displayCode == displayCode }) else {
            return nil
        }
        self = currency
    }

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .algorand:
            return .algo
        case .bitcoin:
            return .bitcoin
        case .bitcoinCash:
            return .bitcoinCash
        case .ethereum:
            return .ethereum
        case .pax:
            return .usdd
        case .stellar:
            return .stellar
        }
    }

    // MARK: Filled small image

    public var filledImageSmallName: String {
        switch self {
        case .algorand:
            return "filled_algo_small"
        case .bitcoin:
            return "filled_btc_small"
        case .bitcoinCash:
            return "filled_bch_small"
        case .ethereum:
            return "filled_eth_small"
        case .pax:
            return "filled_pax_small"
        case .stellar:
            return "filled_xlm_small"
        }
    }

    // MARK: Filled large image

    public var filledImageLargeName: String {
        switch self {
        case .algorand:
            return "filled_algo_large"
        case .bitcoin:
            return "filled_btc_large"
        case .bitcoinCash:
            return "filled_bch_large"
        case .ethereum:
            return "filled_eth_large"
        case .pax:
            return "filled_pax_large"
        case .stellar:
            return "filled_xlm_large"
        }
    }

    public var logoImageName: String {
        switch self {
        case .algorand:
            return "filled_algo_large"
        case .bitcoin:
            return "filled_btc_small"
        case .bitcoinCash:
            return "filled_bch_large"
        case .ethereum:
            return "filled_eth_large"
        case .pax:
            return "filled_pax_large"
        case .stellar:
            return "filled_xlm_large"
        }
    }

    public var whiteImageName: String {
        switch self {
        case .algorand:
            return "white_alg_small"
        case .bitcoin:
            return "white_btc_small"
        case .bitcoinCash:
            return "white_bch_small"
        case .ethereum:
            return "white_eth_small"
        case .pax:
            return "white_pax_small"
        case .stellar:
            return "white_xlm_small"
        }
    }

    public var symbolImageTemplate: UIImage {
        switch self {
        case .algorand:
            return .init() // TICKET: IOS-3492 Algorand: Use correct asset
        case .bitcoin:
            return #imageLiteral(resourceName: "symbol-btc")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "symbol-bch")
        case .ethereum:
            return #imageLiteral(resourceName: "symbol-eth")
        case .pax:
            return #imageLiteral(resourceName: "symbol-eth")
        case .stellar:
            return #imageLiteral(resourceName: "symbol-xlm")
        }
    }

    public var errorImage: UIImage {
        switch self {
        case .algorand:
            return #imageLiteral(resourceName: "alg_bad")
        case .bitcoin:
            return #imageLiteral(resourceName: "btc_bad")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "bch_bad")
        case .ethereum:
            return #imageLiteral(resourceName: "eth_bad")
        case .pax:
            return #imageLiteral(resourceName: "eth_bad")
        case .stellar:
            return #imageLiteral(resourceName: "xlm_bad")
        }
    }

    public var successImage: UIImage {
        switch self {
        case .algorand:
            return #imageLiteral(resourceName: "alg_good")
        case .bitcoin:
            return #imageLiteral(resourceName: "btc_good")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "bch_good")
        case .ethereum:
            return #imageLiteral(resourceName: "eth_good")
        case .pax:
            return #imageLiteral(resourceName: "eth_good")
        case .stellar:
            return #imageLiteral(resourceName: "xlm_good")
        }
    }

    public var whiteImageSmall: UIImage {
        UIImage(named: whiteImageName)!
    }

    public var logo: UIImage {
        UIImage(named: logoImageName)!
    }

    public var filledImageLarge: UIImage {
        UIImage(named: filledImageLargeName)!
    }

    public var filledImageSmall: UIImage {
        UIImage(named: filledImageSmallName)!
    }
}
