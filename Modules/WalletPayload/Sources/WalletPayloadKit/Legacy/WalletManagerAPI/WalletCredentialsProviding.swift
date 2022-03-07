// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol WalletCredentialsProviding: AnyObject {
    var legacyPassword: String? { get }
}
