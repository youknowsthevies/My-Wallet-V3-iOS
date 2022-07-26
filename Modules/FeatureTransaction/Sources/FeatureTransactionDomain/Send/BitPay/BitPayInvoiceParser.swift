// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import MoneyKit
import PlatformKit

enum BitPayInvoiceParser {

    static func make(
        from data: String,
        asset: CryptoCurrency
    ) -> Result<String, BitPayError> {
        guard BitPayInvoiceTarget.isBitPay(data) else {
            return .failure(.invalidBitPayURL)
        }
        guard BitPayInvoiceTarget.isSupportedAsset(asset) else {
            return .failure(.invalidBitPayURL)
        }
        return invoiceId(from: data)
    }

    // MARK: - Private Functions

    private static func invoiceId(from data: String) -> Result<String, BitPayError> {
        guard let url = URL(string: data) else {
            return .failure(.missingInvoiceID)
        }
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .failure(.missingInvoiceID)
        }
        guard let match = components.queryItems?.first(where: { $0.name == "r" })?.value else {
            return .failure(.missingInvoiceID)
        }
        guard let url = URL(string: match) else {
            return .failure(.missingInvoiceID)
        }
        return .success(url.lastPathComponent)
    }
}
