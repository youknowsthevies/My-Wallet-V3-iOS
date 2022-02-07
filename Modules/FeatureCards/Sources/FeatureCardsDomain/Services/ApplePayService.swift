// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

final class ApplePayService: NSObject, ApplePayServiceAPI {

    private let repository: ApplePayRepositoryAPI
    private let authorizationService: ApplePayAuthorizationServiceAPI

    init(
        repository: ApplePayRepositoryAPI,
        authorizationService: ApplePayAuthorizationServiceAPI
    ) {
        self.repository = repository
        self.authorizationService = authorizationService
    }

    func getToken(amount: Decimal, currencyCode: String) -> AnyPublisher<ApplePayParameters, ApplePayError> {
        repository
            .applePayInfo(for: currencyCode)
            .mapError(ApplePayError.nabu)
            .flatMap { [authorizationService] info in
                authorizationService
                    .getToken(amount: amount, currencyCode: currencyCode, info: info)
                    .map { token in
                        ApplePayParameters(token: token, beneficiaryId: info.beneficiaryID)
                    }
            }
            .eraseToAnyPublisher()
    }
}
