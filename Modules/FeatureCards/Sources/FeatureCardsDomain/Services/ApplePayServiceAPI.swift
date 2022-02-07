// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

public protocol ApplePayServiceAPI: AnyObject {
    func getToken(
        amount: Decimal,
        currencyCode: String
    ) -> AnyPublisher<ApplePayParameters, ApplePayError>
}

public enum ApplePayError: Error {
    case invalidTokenParameters
    case invalidInputParameters
    case cancelled
    case nabu(NabuNetworkError)
}
