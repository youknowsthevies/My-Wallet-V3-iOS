// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension String {

    /// Returns the first 5 characters of the SHA256 hash of this string
    var passwordPartHash: String? {
        let hashedString = sha256
        let endIndex = hashedString.index(hashedString.startIndex, offsetBy: min(self.count, 5))
        return String(hashedString[..<endIndex])
    }
}

// MARK: - Symbol formatting
extension String {
    func appendAssetSymbol(for assetType: CryptoCurrency) -> String {
        self + " " + assetType.displayCode
    }

    func appendCurrencySymbol() -> String {
        BlockchainSettings.App.shared.fiatCurrency.symbol + self
    }
}
