// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum WalletError: Error, Equatable {
    case notInitialized
    case failedToSaveKeyPair(String)
    case failedToSaveMemo
    case unknown
}
