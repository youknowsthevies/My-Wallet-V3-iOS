// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CryptoKit

extension String {

    public var sha256: String {
        digestCryptoHex(input: Data(utf8))
    }

    private func digestCryptoHex(input: Data) -> String {
        let hash = CryptoKit.SHA256.hash(data: input)
        return hash.compactMap { String(format: "%02x", $0) }.joined()
    }
}
