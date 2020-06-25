//
//  AssetURLPayloadFactory.swift
//  Blockchain
//
//  Created by Chris Arriola on 6/5/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import BitcoinKit
import EthereumKit
import Foundation
import PlatformKit
import ToolKit

@objc class AssetURLPayloadFactory: NSObject {

    @objc static func scheme(forAsset asset: LegacyCryptoCurrency) -> String? {
        switch asset.value {
        case .bitcoin:
            return BitcoinURLPayload.scheme
        case .bitcoinCash:
            return BitcoinCashURLPayload.scheme
        case .stellar:
            return StellarURLPayload.scheme
        case .pax:
            return EthereumURLPayload.scheme
        default:
            return nil
        }
    }

    @objc
    static func create(fromString string: String, asset: LegacyCryptoCurrency) -> AssetURLPayload? {
        AssetURLPayloadFactory.create(fromString: string, asset: asset.value)
    }
    
    static func create(fromString string: String, asset: CryptoCurrency) -> AssetURLPayload? {
        if string.contains(":") {
            guard let url = URL(string: string) else {
                Logger.shared.warning("Could not create payload from URL \(string)")
                return nil
            }
            return create(from: url)
        } else {
            switch asset {
            case .bitcoin:
                return BitcoinURLPayload(address: string, amount: nil, paymentRequestUrl: nil)
            case .bitcoinCash:
                return BitcoinCashURLPayload(address: string, amount: nil, paymentRequestUrl: nil)
            case .stellar:
                return StellarURLPayload(address: string, amount: nil)
            case .pax, .ethereum:
                return EthereumURLPayload(address: string, amount: nil)
            default:
                return nil
            }
        }
    }

    @objc static func create(from url: URL) -> AssetURLPayload? {
        guard let scheme = url.scheme else {
            Logger.shared.warning("Cannot create AssetURLPayload. Scheme is nil.")
            return nil
        }

        switch scheme {
        case BitcoinURLPayload.scheme:
            return BitcoinURLPayload(url: url)
        case BitcoinCashURLPayload.scheme:
            return BitcoinCashURLPayload(url: url)
        case StellarURLPayload.scheme:
            return StellarURLPayload(url: url)
        case EthereumURLPayload.scheme:
            return EthereumURLPayload(url: url)
        default:
            return nil
        }
    }
}
