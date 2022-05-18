// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import NetworkKit

/// Provides the Exchange website url.
/// - Returns: `String`
public func exchangeUrlProvider() -> String {
    BlockchainAPI.shared.exchangeURL
}
