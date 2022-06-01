// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Errors
import ToolKit

public protocol PendingTransactionRepositoryAPI {
    func isWaitingOnTransaction(
        network: EVMNetwork,
        address: String
    ) -> AnyPublisher<Bool, NetworkError>
}
