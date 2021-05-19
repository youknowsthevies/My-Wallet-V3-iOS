// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import PlatformKit

protocol TokenRepositoryAPI {

    var token: AnyPublisher<String?, Never> { get }
}

class TokenRepository: TokenRepositoryAPI {

    let token: AnyPublisher<String?, Never>

    init(nabuTokenStore: NabuTokenStore = resolve()) {
        self.token = nabuTokenStore.sessionTokenDataPublisher
            .map { $0?.token }
            .eraseToAnyPublisher()
    }
}
