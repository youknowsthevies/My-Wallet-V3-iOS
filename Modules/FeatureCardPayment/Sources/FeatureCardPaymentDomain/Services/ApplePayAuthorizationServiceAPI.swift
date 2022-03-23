// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public protocol ApplePayAuthorizationServiceAPI: AnyObject {

    func getToken(
        amount: Decimal,
        currencyCode: String,
        info: ApplePayInfo
    ) -> AnyPublisher<ApplePayToken, ApplePayError>
}
