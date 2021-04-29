// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct AlgorandURLPayload: CryptoAssetQRMetadata {
    
    public static let scheme: String = ""
    
    public let cryptoCurrency: CryptoCurrency = .algorand
    public let address: String
    public let amount: String? = nil
    public let paymentRequestUrl: String? = nil
    public let includeScheme: Bool = false
    
    public var absoluteString: String {
        address
    }
    
    public init(address: String) {
        self.address = address
    }
}
