// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

final class CryptoFeeServiceMock<FeeType: TransactionFee & Decodable>: CryptoFeeServiceAPI {

    var underlyingFees: FeeType!

    var fees: AnyPublisher<FeeType, Never> {
        .just(underlyingFees)
    }

    init(underlyingFees: FeeType? = FeeType.default) {
        self.underlyingFees = underlyingFees
    }
}
