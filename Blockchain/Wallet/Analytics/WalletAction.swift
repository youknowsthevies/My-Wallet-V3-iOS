// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates actions that can be performed on the wallet (e.g. send crypto, receive crypto, etc.)
@objc enum WalletAction: Int, CaseIterable {
    case sendCrypto
    case receiveCrypto
    case buyCryptoWithFiat
    case sellCryptoToFiat
}
