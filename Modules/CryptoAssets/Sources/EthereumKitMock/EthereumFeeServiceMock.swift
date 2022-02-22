// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import MoneyKit
import PlatformKit

class EthereumFeeServiceMock: EthereumFeeServiceAPI {
    var underlyingFees: EthereumTransactionFee

    func fees(cryptoCurrency: CryptoCurrency) -> AnyPublisher<EthereumTransactionFee, Never> {
        .just(underlyingFees)
    }

    init(underlyingFees: EthereumTransactionFee) {
        self.underlyingFees = underlyingFees
    }
}
