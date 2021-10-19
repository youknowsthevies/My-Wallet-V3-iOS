// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

/// A Publisher that provides easy access to `WalletStorageState` for related inforation
@dynamicMemberLookup
public struct WalletStorage: Publisher {
    public typealias Output = WalletStorageState
    public typealias Failure = Never

    public let upstream: AnyPublisher<WalletStorageState, Never>

    private var state: CurrentValueSubject<WalletStorageState, Never>

    public init(initialState: WalletStorageState) {
        state = CurrentValueSubject<WalletStorageState, Never>(initialState)
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
        dynamicMember keyPath: KeyPath<WalletStorageState, LocalState>
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
    public func set<Value>(
        keyPath: WritableKeyPath<WalletStorageState, Value>,
        value: Value
    ) {
        state.value[keyPath: keyPath] = value
    }

    /// Sets an new `WalletStorageState` value
    /// - Parameter value: A `WalletStorageState` to be set.
    public func set(
        value: WalletStorageState
    ) {
        state.send(value)
    }
}
