// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import Foundation

public protocol EligibleCardAcquirersAPI: AnyObject {
    /// Get the list of enabled card acquirers (Stripe, Checkout.com, ...) and their account codes to tokenise new payment cards.
    /// - Returns: A `Combine.Publisher` that publishes a `[PaymentCardAcquirer]` if success or `NabuNetworkError` if failed.
    func paymentsCardAcquirers() -> AnyPublisher<[PaymentCardAcquirer], NabuNetworkError>
}
