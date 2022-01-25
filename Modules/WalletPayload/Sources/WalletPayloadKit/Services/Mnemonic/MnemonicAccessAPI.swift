// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation

public typealias Mnemonic = String

public enum MnemonicAccessError: Error {
    case generic
    case wrongSecondPassword
    case couldNotRetrieveMnemonic(WalletError)
}

/// Users can double encrypt their wallet. If this is the case, sometimes users will
/// need to enter in their secondary password before performing certain actions. This is
/// **not** currency or asset specific
public protocol MnemonicAccessAPI {

    /// Returns a `AnyPublisher<Mnemonic, MnemonicAccessError>` emitting
    /// a Mnemonic if and only if the mnemonic is not double encrypted
    var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> { get }

    /// Returns a `AnyPublisher<Mnemonic, MnemonicAccessError>` using optionally a second password
    /// - Parameter secondPassword: An optional `String` value for a double encrypted wallet
    func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError>

    /// Returns a `AnyPublisher<Mnemonic, MnemonicAccessError>` emitting a Mnemonic.
    /// This will prompt the user to enter the second password if needed.
    var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> { get }
}

public final class MnemonicAccessService: MnemonicAccessAPI {

    public var mnemonic: AnyPublisher<Mnemonic, MnemonicAccessError> {
        walletHolder.walletStatePublisher
            .flatMap { state -> AnyPublisher<NativeWallet, MnemonicAccessError> in
                guard let wallet = state?.wallet else {
                    return .failure(.generic)
                }
                return .just(wallet)
            }
            .flatMap { wallet -> AnyPublisher<Mnemonic, MnemonicAccessError> in
                getMnemonic(from: wallet)
                    .publisher
                    .mapError { _ in MnemonicAccessError.wrongSecondPassword }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    public var mnemonicPromptingIfNeeded: AnyPublisher<Mnemonic, MnemonicAccessError> {
        secondPasswordPrompter()
            .flatMap { [walletHolder] secondPassword -> AnyPublisher<String, MnemonicAccessError> in
                retrieveMnemonic(
                    secondPassword: secondPassword,
                    walletHolder: walletHolder
                )
            }
            .eraseToAnyPublisher()
    }

    private let walletHolder: WalletHolderAPI
    private let secondPasswordPrompter: () -> AnyPublisher<String?, MnemonicAccessError>

    init(
        walletHolder: WalletHolderAPI,
        secondPasswordPrompter: @escaping () -> AnyPublisher<String?, MnemonicAccessError>
    ) {
        self.walletHolder = walletHolder
        self.secondPasswordPrompter = secondPasswordPrompter
    }

    public convenience init(secondPasswordPrompter: @escaping () -> AnyPublisher<String?, MnemonicAccessError>) {
        self.init(
            walletHolder: DIKit.resolve(),
            secondPasswordPrompter: secondPasswordPrompter
        )
    }

    public func mnemonic(with secondPassword: String?) -> AnyPublisher<Mnemonic, MnemonicAccessError> {
        retrieveMnemonic(
            secondPassword: secondPassword,
            walletHolder: walletHolder
        )
    }
}

/// Retrieves a mnemonic from a given `Wallet`
/// - Parameters:
///   - secondPassword: An optional `String` value for a double encrypted wallet
///   - walletHolder: A `WalletHolderAPI` object to retrieve the `Wallet` from
/// - Returns: An `AnyPublisher<Mnemonic, MnemonicAccessError>` emitting a Mnemonic or failure
private func retrieveMnemonic(
    secondPassword: String?,
    walletHolder: WalletHolderAPI
) -> AnyPublisher<Mnemonic, MnemonicAccessError> {
    walletHolder.walletStatePublisher
        .flatMap { state -> AnyPublisher<NativeWallet, MnemonicAccessError> in
            guard let wallet = state?.wallet else {
                return .failure(.generic)
            }
            return .just(wallet)
        }
        .flatMap { wallet -> AnyPublisher<Mnemonic, MnemonicAccessError> in
            getMnemonic(from: wallet, secondPassword: secondPassword)
                .publisher
                .mapError(MnemonicAccessError.couldNotRetrieveMnemonic)
                .eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
}
