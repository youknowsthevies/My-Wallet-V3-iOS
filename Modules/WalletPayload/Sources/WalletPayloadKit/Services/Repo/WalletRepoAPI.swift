// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

@dynamicMemberLookup
public protocol WalletRepoAPI {

    /// Gets the current value of the `WalletRepoState`
    /// - Returns: `Publishers.First<AnyPublisher<WalletRepoState, Never>>`
    func get() -> Publishers.First<AnyPublisher<WalletRepoState, Never>>

    /// Streams the value of the underlying state of `WalletRepoState`
    /// - Returns: `AnyPublisher<WalletRepoState, Never>`
    func stream() -> AnyPublisher<WalletRepoState, Never>

    /// Sets the given value on the selected keyPath and return the updated state as a stream.
    ///
    /// - Parameters:
    ///   - keyPath: A `WritableKeyPath` for the underlying variable
    ///   - value: A value to be to written for the selected keyPath
    @discardableResult
    func set<Value>(
        keyPath: WritableKeyPath<WalletRepoState, Value>,
        value: Value
    ) -> Self

    /// Sets an new `WalletStorageState` value
    ///
    /// - Parameter value: A `WalletStorageState` to be set.
    @discardableResult
    func set(
        value: WalletRepoState
    ) -> Self

    /// Returns the resulting value of a given key path.
    subscript<LocalState>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> LocalState { get }

    /// Returns the resulting publisher of a given key path.
    subscript<LocalState: Equatable>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> AnyPublisher<LocalState, Never> { get }
}
