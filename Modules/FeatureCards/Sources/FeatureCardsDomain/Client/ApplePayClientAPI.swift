// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NabuNetworkError

public protocol ApplePayClientAPI: AnyObject {
    func applePayInfo(
        for currency: String
    ) -> AnyPublisher<ApplePayInfo, NabuNetworkError>
}

public protocol ApplePayEligibleServiceAPI: AnyObject {
    func isFrontendEnabled() -> AnyPublisher<Bool, Never>
    func isBackendEnabled() -> AnyPublisher<Bool, Never>
}
