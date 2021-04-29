// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol WalletCredentialsProviding: class {
    var legacyPassword: String? { get }
}
