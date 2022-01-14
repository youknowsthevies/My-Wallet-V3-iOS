// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

@dynamicMemberLookup
public protocol WalletRepoAPI {

    /// The underlying publisher, `AnyPublisher<WalletRepoState, Never>`
    var publisher: AnyPublisher<WalletRepoState, Never> { get }

    /// Sets the given value on the selected keyPath
    /// - Parameters:
    ///   - keyPath: A `WritableKeyPath` for the underlying variable
    ///   - value: A value to be to written for the selected keyPath
    @discardableResult
    func set<Value>(
        keyPath: WritableKeyPath<WalletRepoState, Value>,
        value: Value
    ) -> Self

    /// Sets an new `WalletStorageState` value
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
