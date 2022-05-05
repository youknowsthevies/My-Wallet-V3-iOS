// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum WalletUpgradeError: Error {
    case errorUpgrading(version: String)
    case upgradeFailed
    case unableToRetrieveSeedHex
    case mnemonicFailure(MnemonicProviderError)
    case walletCreateError(WalletCreateError)
}
