// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum WalletRecovery: Equatable {
    case metadataRecovery(seedPhrase: String)
    case importRecovery(email: String, newPassword: String, seedPhrase: String)
    case resetAccountRecovery(email: String, newPassword: String, nabuInfo: WalletInfo.Nabu)
}
