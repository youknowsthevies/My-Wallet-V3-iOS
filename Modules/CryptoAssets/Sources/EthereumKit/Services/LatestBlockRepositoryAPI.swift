// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Combine
import NetworkError

public protocol LatestBlockRepositoryAPI {
    func latestBlock(
        network: EVMNetwork
    ) -> AnyPublisher<BigInt, NetworkError>
}
