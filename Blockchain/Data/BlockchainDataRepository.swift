// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import PlatformKit
import ToolKit

/// Repository for fetching Blockchain data. Accessing properties in this repository
/// will be fetched from the cache (if available), otherwise, data will be fetched over
/// the network and subsequently cached for faster access.
final class BlockchainDataRepository: DataRepositoryAPI {

    var user: AnyPublisher<User, Never> {
        nabuUserService.user
            .map { $0 }
            .eraseToAnyPublisher()
    }

    private let nabuUserService: NabuUserServiceAPI

    init(nabuUserService: NabuUserServiceAPI = resolve()) {
        self.nabuUserService = nabuUserService
    }
}
