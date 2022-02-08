// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import ToolKit
import WalletCore

public enum WalletCreateError: Error, Equatable {
    case genericFailure
    case mnemonicFailure(MnemonicProviderError)
    case uuidFailure
}

struct WalletCreationContext: Equatable {
    let mnemonic: String
    let guid: String
    let sharedKey: String
    let accountName: String
}

typealias UUIDProvider = () -> AnyPublisher<(guid: String, sharedKey: String), WalletCreateError>
typealias GenerateWalletProvider = (WalletCreationContext) -> Result<NativeWallet, WalletCreateError>

public protocol WalletCreatorAPI {
    func createWallet(
        email: String,
        password: String,
        accountName: String
    ) -> AnyPublisher<EmptyValue, WalletCreateError>
}

final class WalletCreator: WalletCreatorAPI {

    private let entropyService: RNGServiceAPI
    private let uuidProvider: UUIDProvider
    private let generateWalletProvider: GenerateWalletProvider

    init(
        entropyService: RNGServiceAPI,
        uuidProvider: @escaping UUIDProvider,
        generateWalletProvider: @escaping GenerateWalletProvider
    ) {
        self.uuidProvider = uuidProvider
        self.entropyService = entropyService
        self.generateWalletProvider = generateWalletProvider
    }

    func createWallet(
        email: String,
        password: String,
        accountName: String
    ) -> AnyPublisher<EmptyValue, WalletCreateError> {
        provideMnemonic(
            strength: .normal,
            entropyProvider: entropyService.generateEntropy(count:)
        )
        .mapError(WalletCreateError.mnemonicFailure)
        .flatMap { [uuidProvider] mnemonic -> AnyPublisher<WalletCreationContext, WalletCreateError> in
            uuidProvider()
                .map { guid, sharedKey in
                    WalletCreationContext(
                        mnemonic: mnemonic,
                        guid: guid,
                        sharedKey: sharedKey,
                        accountName: accountName
                    )
                }
                .eraseToAnyPublisher()
        }
        .flatMap { [generateWalletProvider] context -> AnyPublisher<NativeWallet, WalletCreateError> in
            generateWalletProvider(context)
                .publisher
                .eraseToAnyPublisher()
        }
        .map { _ in .noValue }
        .eraseToAnyPublisher()
    }
}

/// Provides UUIDs to be used as guid and sharedKey in wallet creation
/// - Returns: `AnyPublisher<(guid: String, sharedKey: String), WalletCreateError>`
func uuidProvider() -> AnyPublisher<(guid: String, sharedKey: String), WalletCreateError> {
    let guid = UUID().uuidString.lowercased()
    let sharedKey = UUID().uuidString.lowercased()
    guard guid.count == 36 || sharedKey.count == 36 else {
        return .failure(.uuidFailure)
    }
    return .just((guid, sharedKey))
}
