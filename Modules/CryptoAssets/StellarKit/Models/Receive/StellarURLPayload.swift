// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import stellarsdk

public struct StellarURLPayload: SEP7URI {

    public static var scheme: String {
        AssetConstants.URLSchemes.stellar
    }

    public let cryptoCurrency: CryptoCurrency = .stellar
    public let address: String
    public let amount: String?
    public let paymentRequestUrl: String? = nil
    public let includeScheme: Bool = true
    public let memo: String?

    public var absoluteString: String {
        var amountInDecimal: Decimal?
        if let amount = amount {
            amountInDecimal = Decimal(string: amount)
        }
        return URIScheme().getPayOperationURI(accountID: address, amount: amountInDecimal, memo: memo)
    }

    public init(address: String, amount: String?, memo: String?) {
        self.address = address
        self.amount = amount
        self.memo = memo
    }

    public init?(url: URL) {
        // Scheme must 'be web+stellar'
        guard StellarURLPayload.scheme == url.scheme else {
            return nil
        }

        // Get query arguments after "web+stellar:pay?". We do not support actions other than 'pay'.
        guard let arguments = url.absoluteString.components(separatedBy: "\(StellarURLPayload.scheme):\(PayOperation)").last else {
            return nil
        }
        let queryArguments = arguments.queryArgs
        // We must have an destination
        guard let destination = queryArguments["\(PayOperationParams.destination)"] else {
            return nil
        }

        // Optionally retrieve payment amount.
        let amount: String? = queryArguments["\(PayOperationParams.amount)"]

        // Optionally retrieve memo if memo type is text.
        var memo: String?
        let memoType: String? = queryArguments["\(PayOperationParams.memo_type)"]
        if memoType == nil || memoType == "MEMO_TEXT" {
            memo = queryArguments["\(PayOperationParams.memo)"]
        }

        self.init(address: destination, amount: amount, memo: memo)
    }
}
