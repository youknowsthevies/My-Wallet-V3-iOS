// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol DataRepositoryAPI {
    var user: AnyPublisher<User, Never> { get }
}
