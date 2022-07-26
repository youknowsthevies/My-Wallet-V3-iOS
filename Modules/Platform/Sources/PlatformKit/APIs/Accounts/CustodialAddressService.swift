// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors
import MoneyKit

public protocol CustodialAddressServiceAPI {

    func receiveAddress(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<String, NabuNetworkError>
}

final class CustodialAddressService: CustodialAddressServiceAPI {

    private let client: CustodialPaymentAccountClientAPI

    // MARK: - Setup

    init(client: CustodialPaymentAccountClientAPI) {
        self.client = client
    }

    func receiveAddress(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<String, NabuNetworkError> {
        client.custodialPaymentAccount(for: cryptoCurrency)
            .map(\.account)
            .map(\.address)
            .eraseToAnyPublisher()
    }
}
