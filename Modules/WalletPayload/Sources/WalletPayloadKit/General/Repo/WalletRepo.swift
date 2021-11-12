// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// A Publisher that provides easy access to `WalletRepoState` for related information
@dynamicMemberLookup
public struct WalletRepo: Publisher {
    public typealias Output = WalletRepoState
    public typealias Failure = Never

    public let upstream: AnyPublisher<WalletRepoState, Never>

    private var state: CurrentValueSubject<WalletRepoState, Never>

    public init(initialState: WalletRepoState) {
        state = CurrentValueSubject<WalletRepoState, Never>(initialState)
        upstream = state.eraseToAnyPublisher()
    }

    public func receive<S>(subscriber: S)
        where S: Subscriber, Failure == S.Failure, Output == S.Input
    {
        upstream.subscribe(
            AnySubscriber(
                receiveSubscription: subscriber.receive(subscription:),
                receiveValue: subscriber.receive(_:),
                receiveCompletion: {
                    subscriber.receive(completion: $0)
                }
            )
        )
    }

    /// Returns the resulting value of a given key path.
    public subscript<LocalState>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> LocalState {
        state.value[keyPath: keyPath]
    }

    /// Returns the resulting publisher of a given key path.
    public subscript<LocalState>(
        dynamicMember keyPath: KeyPath<Output, LocalState>
    ) -> AnyPublisher<LocalState, Never>
        where LocalState: Equatable
    {
        upstream.map(keyPath)
            .eraseToAnyPublisher()
    }

    /// Sets the given value on the selected keyPath
    /// - Parameters:
    ///   - keyPath: A `WritableKeyPath` for the underlying variable
    ///   - value: A value to be to written for the selected keyPath
    @discardableResult
    public func set<Value>(
        keyPath: WritableKeyPath<WalletRepoState, Value>,
        value: Value
    ) -> Self {
        state.value[keyPath: keyPath] = value
        return self
    }

    /// Sets an new `WalletStorageState` value
    /// - Parameter value: A `WalletStorageState` to be set.
    @discardableResult
    public func set(
        value: WalletRepoState
    ) -> Self {
        state.send(value)
        return self
    }
}
