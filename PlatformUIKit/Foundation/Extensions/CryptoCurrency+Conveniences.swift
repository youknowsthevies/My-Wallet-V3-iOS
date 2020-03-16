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
    
    /// Initialize with a display currency code: `BTC`, `ETH`, `BCH`, `XLM`, `USD-D`
    public init?(displayCode: String) {
        guard let currency = (CryptoCurrency.allCases.first { $0.displayCode == displayCode }) else {
            return nil
        }
        self = currency
    }
    
    // MARK: - UIColor
    
    public var brandColor: UIColor {
        switch self {
        case .bitcoin:
            return .bitcoin
        case .ethereum:
            return .ethereum
        case .bitcoinCash:
            return .bitcoinCash
        case .stellar:
            return .stellar
        case .pax:
            return .usdd
        }
    }
    
    // MARK: Filled small image
    
    public var filledImageSmallName: String {
        switch self {
        case .bitcoin:
            return "filled_btc_small"
        case .bitcoinCash:
            return "filled_bch_small"
        case .ethereum:
            return "filled_eth_small"
        case .stellar:
            return "filled_xlm_small"
        case .pax:
            return "filled_pax_small"
        }
    }

    // MARK: Filled large image
    
    public var filledImageLargeName: String {
        switch self {
        case .bitcoin:
            return "filled_btc_large"
        case .bitcoinCash:
            return "filled_bch_large"
        case .ethereum:
            return "filled_eth_large"
        case .stellar:
            return "filled_xlm_large"
        case .pax:
            return "filled_pax_large"
        }
    }

    public var logoImageName: String {
        switch self {
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
    
    public var whiteImageSmall: UIImage {
        switch self {
        case .bitcoin:
            return #imageLiteral(resourceName: "white_btc_small")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "white_bch_small")
        case .ethereum:
            return #imageLiteral(resourceName: "white_eth_small")
        case .stellar:
            return #imageLiteral(resourceName: "white_xlm_small")
        case .pax:
            return #imageLiteral(resourceName: "white_pax_small")
        }
    }

    public var symbolImageTemplate: UIImage {
        switch self {
        case .bitcoin:
            return #imageLiteral(resourceName: "symbol-btc")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "symbol-bch")
        case .ethereum:
            return #imageLiteral(resourceName: "symbol-eth")
        case .stellar:
            return #imageLiteral(resourceName: "symbol-xlm")
        case .pax:
            return #imageLiteral(resourceName: "symbol-eth")
        }
    }
    
    public var errorImage: UIImage {
        switch self {
        case .bitcoin:
            return #imageLiteral(resourceName: "btc_bad.pdf")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "bch_bad.pdf")
        case .ethereum:
            return #imageLiteral(resourceName: "eth_bad.pdf")
        case .stellar:
            return #imageLiteral(resourceName: "xlm_bad.pdf")
        case .pax:
            return #imageLiteral(resourceName: "eth_bad.pdf")
        }
    }
    
    public var successImage: UIImage {
        switch self {
        case .bitcoin:
            return #imageLiteral(resourceName: "btc_good.pdf")
        case .bitcoinCash:
            return #imageLiteral(resourceName: "bch_good.pdf")
        case .ethereum:
            return #imageLiteral(resourceName: "eth_good.pdf")
        case .stellar:
            return #imageLiteral(resourceName: "xlm_good.pdf")
        case .pax:
            return #imageLiteral(resourceName: "eth_good.pdf")
        }
    }
    
    public var logo: UIImage {
        return UIImage(named: logoImageName)!
    }
    
    public var filledImageLarge: UIImage {
        return UIImage(named: filledImageLargeName)!
    }
    
    public var filledImageSmall: UIImage {
        return UIImage(named: filledImageSmallName)!
    }
}
