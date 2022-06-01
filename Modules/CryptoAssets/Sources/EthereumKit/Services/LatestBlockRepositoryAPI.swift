// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import Errors

public protocol LatestBlockRepositoryAPI {
    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<BigInt, NetworkError>
}
