// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public class EthereumURLPayload: EIP67URI {
    
    private enum QueryItemKeys: String {
        case value
        case gas
    }
    
    public static var scheme: String {
        AssetConstants.URLSchemes.ethereum
    }

    public let cryptoCurrency: CryptoCurrency = .ethereum
    public let address: String
    public private(set) var amount: String?
    public private(set) var gas: String?
    public private(set) var paymentRequestUrl: String?
    public let includeScheme: Bool = false
    
    public var absoluteString: String {
        var components = self.components
        if !includeScheme {
            components.scheme = nil
        }
        return components.url!.absoluteString
    }
    
    private let components: URLComponents
    
    required public init?(address: String, amount: String? = nil, gas: String? = nil) {
        let components = EthereumURLPayload.urlComponents(from: address, amount: amount, gas: gas)
        guard EthereumURLPayload.valid(components: components) else {
            return nil
        }
        self.components = components
        self.address = address
        self.amount = amount
        self.gas = gas
    }
    
    required convenience public init?(url: URL) {
        self.init(rawValue: url.absoluteString)
    }
    
    required public init?(rawValue: String) {
        guard let components: URLComponents = URLComponents(string: rawValue) else {
            return nil
        }

        guard EthereumURLPayload.valid(components: components) else {
            return nil
        }

        self.components = components
        self.address = components.path

        if let queryItems = components.queryItems {
            for item in queryItems {
                if let key = QueryItemKeys(rawValue: item.name) {
                    switch key {
                    case .value:
                        self.amount = item.value
                    case .gas:
                        self.gas = item.value
                    }
                }
            }
        }
    }
    
    private static func valid(components: URLComponents) -> Bool {
        components.scheme == EthereumURLPayload.scheme && components.path.count == 42
    }
    
    private static func urlComponents(from address: String, amount: String?, gas: String?) -> URLComponents {
        var components = URLComponents()
        components.scheme = EthereumURLPayload.scheme
        components.path = address
        
        var queryItems: [URLQueryItem] = []
        if let amount = amount {
            queryItems.append(URLQueryItem(name: QueryItemKeys.value.rawValue, value: amount))
        }
        if let gas = gas {
            queryItems.append(URLQueryItem(name: QueryItemKeys.gas.rawValue, value: gas))
        }
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }
        
        return components
    }
}
