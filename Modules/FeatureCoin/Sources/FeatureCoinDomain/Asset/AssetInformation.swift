import Foundation
import MoneyKit

public struct AssetInformation: Codable, Hashable {

    public let currencyInfo: CurrencyInfo
    public let description: String?
    public let whitepaper: String?
    public let website: String?
    public let language: String?

    public init(
        currencyInfo: AssetInformation.CurrencyInfo,
        description: String?,
        whitepaper: String?,
        website: String?,
        language: String?
    ) {
        self.currencyInfo = currencyInfo
        self.description = description
        self.whitepaper = whitepaper
        self.website = website
        self.language = language
    }

    public var whitepaperURL: URL? {
        whitepaper.flatMap(URL.init(string:))
    }

    public var websiteURL: URL? {
        website.flatMap(URL.init(string:))
    }
}

extension AssetInformation {

    public struct CurrencyInfo: Codable, Hashable {

        public let symbol: String
        public let displaySymbol: String
        public let name: String
        public let type: CurrencyInfoType
        public let precision: Int
        public let products: [String]

        public init(
            symbol: String,
            displaySymbol: String,
            name: String,
            type: AssetInformation.CurrencyInfo.CurrencyInfoType,
            precision: Int,
            products: [String]
        ) {
            self.symbol = symbol
            self.displaySymbol = displaySymbol
            self.name = name
            self.type = type
            self.precision = precision
            self.products = products
        }
    }
}

extension AssetInformation.CurrencyInfo {

    public struct CurrencyInfoType: Codable, Hashable {

        public let name: String
        public let logoPngUrl: URL?

        public init(
            name: String,
            logoPngUrl: URL?
        ) {
            self.name = name
            self.logoPngUrl = logoPngUrl
        }
    }
}

extension AssetInformation {
    public var currency: CryptoCurrency { CryptoCurrency(code: currencyInfo.symbol)! }
}

// swiftlint:disable line_length

extension AssetInformation {

    public static var preview: AssetInformation {
        AssetInformation(
            currencyInfo: AssetInformation.CurrencyInfo(
                symbol: "BTC",
                displaySymbol: "BTC",
                name: "bitcoin",
                type: AssetInformation.CurrencyInfo.CurrencyInfoType(
                    name: "COIN",
                    logoPngUrl: "https://raw.githubusercontent.com/blockchain/coin-definitions/master/extensions/blockchains/bitcoin/info/logo.png"
                ),
                precision: 8,
                products: [
                    "PrivateKey",
                    "CustodialWalletBalance",
                    "InterestBalance"
                ]
            ),
            description: "Bitcoin uses peer-to-peer technology to operate with no central authority or banks; managing transactions and the issuing of bitcoins is carried out collectively by the network. Although other cryptocurrencies have come before, Bitcoin is the first decentralized cryptocurrency - Its reputation has spawned copies and evolution in the space.With the largest variety of markets and the biggest value - having reached a peak of 318 billion USD - Bitcoin is here to stay. As with any new invention, there can be improvements or flaws in the initial model however the community and a team of dedicated developers are pushing to overcome any obstacle they come across. It is also the most traded cryptocurrency and one of the main entry points for all the other cryptocurrencies. The price is as unstable as always and it can go up or down by 10%-20% in a single day.Bitcoin is an SHA-256 POW coin with almost 21,000,000 total minable coins. The block time is 10 minutes. See below for a full range of Bitcoin markets where you can trade US Dollars for Bitcoin, crypto to Bitcoin and many other fiat currencies too.Bitcoin Whitepaper PDF - A Peer-to-Peer Electronic Cash System",
            whitepaper: "https://www.cryptocompare.com/media/37745820/bitcoin.pdf",
            website: "https://bitcoin.org",
            language: "en"
        )
    }
}
