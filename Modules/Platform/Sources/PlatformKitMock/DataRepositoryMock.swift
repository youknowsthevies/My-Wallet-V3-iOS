// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

final class DataRepositoryMock: DataRepositoryAPI {

    var underlyingUser: User = UserMock()

    var user: AnyPublisher<User, Never> {
        .just(underlyingUser)
    }
}
