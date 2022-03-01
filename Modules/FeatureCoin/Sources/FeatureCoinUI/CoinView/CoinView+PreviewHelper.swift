// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureCoinDomain
import Foundation

extension CoinView {
    enum PreviewHelper {
        static let name = "Bitcoin"
        static let code = "BTC"
        // swiftlint:disable line_length
        static let about = "The world’s first cryptocurrency, Bitcoin is stored and exchanged securely on the internet through a digital ledger known as a blockchain. Bitcoins are divisible into smaller units known as satoshis — each satoshi is worth 0.00000001 bitcoin."
        static let url: URL = "https://www.blockchain.com/"
        static let logoResource: URL = "https://cryptologos.cc/logos/bitcoin-btc-logo.png"
    }
}
