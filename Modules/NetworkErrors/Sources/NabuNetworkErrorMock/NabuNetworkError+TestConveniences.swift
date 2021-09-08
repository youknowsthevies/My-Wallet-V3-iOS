// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import NabuNetworkError

extension NabuNetworkError {

    public static let mockError: NabuNetworkError = .nabuError(
        NabuError(
            id: UUID().uuidString,
            code: .badMethod,
            type: .badMethod,
            description: nil
        )
    )
}
