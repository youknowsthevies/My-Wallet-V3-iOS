// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

extension Result {
    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        case .success:
            return false
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}

extension Result {
    public var successData: Success? {
        try? get()
    }
}

extension Result where Success: OptionalProtocol {
    public func onNil(error: Failure) -> Result<Success.Wrapped, Failure> {
        flatMap { element -> Result<Success.Wrapped, Failure> in
            guard let value = element.wrapped else {
                return .failure(error)
            }
            return .success(value)
        }
    }
}

extension Result where Failure == Never {
    public func mapError<E: Error>(to type: E.Type) -> Result<Success, E> {
        mapError()
    }

    public func mapError<E: Error>() -> Result<Success, E> {
        switch self {
        case .success(let value):
            return .success(value)
        }
    }
}

extension Result where Success == Never {
    public func map<T>(to type: T.Type) -> Result<T, Failure> {
        map()
    }

    public func map<T>() -> Result<T, Failure> {
        switch self {
        case .failure(let error):
            return .failure(error)
        }
    }
}

extension Result {
    public func replaceError<E: Error>(with error: E) -> Result<Success, E> {
        mapError { _ in error }
    }
}

extension Result {
    public func eraseError() -> Result<Success, Error> {
        mapError { $0 }
    }
}

extension Result {
    public func reduce<NewValue>(_ transform: (Result<Success, Failure>) -> NewValue) -> NewValue {
        transform(self)
    }
}
