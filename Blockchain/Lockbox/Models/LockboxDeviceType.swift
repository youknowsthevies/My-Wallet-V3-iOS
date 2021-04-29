// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates the different supported types of hardware wallets on Blockchain.
enum LockboxDeviceType: String, Codable {
    case blockchain
    case ledger
}
