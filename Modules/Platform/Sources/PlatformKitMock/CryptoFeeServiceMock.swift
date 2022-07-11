// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

final class CryptoFeeRepositoryMock<FeeType: TransactionFee & Decodable>: CryptoFeeRepositoryAPI {

    var underlyingFees: FeeType!

    var fees: AnyPublisher<FeeType, Never> {
        .just(underlyingFees)
    }

    init(underlyingFees: FeeType? = FeeType.default) {
        self.underlyingFees = underlyingFees
    }
}
