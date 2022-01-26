// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import WalletPayloadKit

final class WalletRepo: WalletRepoAPI {
    private var state: CurrentValueSubject<WalletRepoState, Never>

    var publisher: AnyPublisher<WalletRepoState, Never> {
        state.eraseToAnyPublisher()
    }

    init(initialState: WalletRepoState) {
        state = CurrentValueSubject<WalletRepoState, Never>(initialState)
    }

    /// Returns the resulting value of a given key path.
    subscript<LocalState>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> LocalState {
        state.value[keyPath: keyPath]
    }

    /// Returns the resulting publisher of a given key path.
    subscript<LocalState>(
        dynamicMember keyPath: KeyPath<WalletRepoState, LocalState>
    ) -> AnyPublisher<LocalState, Never>
        where LocalState: Equatable
    {
        state.map(keyPath)
            .eraseToAnyPublisher()
    }

    /// Sets the given value on the selected keyPath
    /// - Parameters:
    ///   - keyPath: A `WritableKeyPath` for the underlying variable
    ///   - value: A value to be to written for the selected keyPath
    @discardableResult
    func set<Value>(
        keyPath: WritableKeyPath<WalletRepoState, Value>,
        value: Value
    ) -> Self {
        state.value[keyPath: keyPath] = value
        return self
    }

    /// Sets an new `WalletStorageState` value
    /// - Parameter value: A `WalletStorageState` to be set.
    @discardableResult
    func set(
        value: WalletRepoState
    ) -> Self {
        state.send(value)
        return self
    }
}
