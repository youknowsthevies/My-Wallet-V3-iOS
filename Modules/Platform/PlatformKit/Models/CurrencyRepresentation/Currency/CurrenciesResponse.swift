// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct CurrenciesResponse: Decodable {
    struct Coin: Decodable {
        let minimumOnChainConfirmations: Int

        enum CodingKeys: String, CodingKey {
            case name
            case minimumOnChainConfirmations
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            guard name == "COIN" else {
                throw DecodingError.dataCorruptedError(
                    forKey: .name,
                    in: container,
                    debugDescription: "Type '\(name)' is not 'COIN'."
                )
            }
            minimumOnChainConfirmations = try container.decode(Int.self, forKey: .minimumOnChainConfirmations)
        }
    }
    struct ERC20: Decodable {
        let parentChain: String
        let erc20Address: String
        let logoPngUrl: String
        let websiteUrl: String

        enum CodingKeys: String, CodingKey {
            case name
            case parentChain
            case erc20Address
            case logoPngUrl
            case websiteUrl
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let name = try container.decode(String.self, forKey: .name)
            guard name == "ERC20" else {
                throw DecodingError.dataCorruptedError(
                    forKey: .name,
                    in: container,
                    debugDescription: "Type '\(name)' is not 'ERC20'."
                )
            }
            parentChain = try container.decode(String.self, forKey: .parentChain)
            erc20Address = try container.decode(String.self, forKey: .erc20Address)
            logoPngUrl = try container.decode(String.self, forKey: .logoPngUrl)
            websiteUrl = try container.decode(String.self, forKey: .websiteUrl)
        }
    }
    enum CurrencyType {
        case coin(Coin)
        case erc20(ERC20)
        case invalid

        var valid: Bool {
            switch self {
            case .invalid:
                return false
            default:
                return true
            }
        }
    }
    struct Currency: Decodable {
        let symbol: String
        let name: String
        let type: CurrencyType
        let precision: Int
        let products: [String]

        enum CodingKeys: String, CodingKey {
            case symbol
            case name
            case type
            case precision
            case products
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            symbol = try container.decode(String.self, forKey: .symbol)
            name = try container.decode(String.self, forKey: .name)
            precision = try container.decode(Int.self, forKey: .precision)
            products = try container.decode([String].self, forKey: .products)

            if let erc20 = try? container.decode(ERC20.self, forKey: .type) {
                self.type = .erc20(erc20)
            } else if let coin = try? container.decode(Coin.self, forKey: .type) {
                self.type = .coin(coin)
            } else {
                self.type = .invalid
            }
        }
    }

    let currencies: [Currency]

    enum CodingKeys: String, CodingKey {
        case currencies
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currencies = try container.decode([Currency].self, forKey: .currencies).filter(\.type.valid)
    }
}
