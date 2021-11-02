// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public enum DataRepositoryError: Error {
    case failedToFetchUser(Error)
}

public protocol DataRepositoryAPI {
    var user: AnyPublisher<User, DataRepositoryError> { get }
}
