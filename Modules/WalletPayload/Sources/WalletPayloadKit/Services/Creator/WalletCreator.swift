// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import NetworkError
import ToolKit
import WalletCore

public enum WalletCreateError: LocalizedError, Equatable {
    case genericFailure
    case expectedEncodedPayload
    case encryptionFailure
    case uuidFailure
    case mnemonicFailure(MnemonicProviderError)
    case encodingError(WalletEncodingError)
    case networkError(NetworkError)
}

struct WalletCreationContext: Equatable {
    let mnemonic: String
    let guid: String
    let sharedKey: String
    let accountName: String
}

typealias UUIDProvider = () -> AnyPublisher<(guid: String, sharedKey: String), WalletCreateError>
typealias GenerateWalletProvider = (WalletCreationContext) -> Result<NativeWallet, WalletCreateError>
typealias GenerateWrapperProvider = (NativeWallet, String, WalletVersion) -> Wrapper

public protocol WalletCreatorAPI {
    func createWallet(
        email: String,
        password: String,
        accountName: String,
        language: String
    ) -> AnyPublisher<EmptyValue, WalletCreateError>
}

final class WalletCreator: WalletCreatorAPI {

    private let entropyService: RNGServiceAPI
    private let walletEncoder: WalletEncodingAPI
    private let encryptor: PayloadCryptoAPI
    private let createWalletRepository: CreateWalletRepositoryAPI
    private let uuidProvider: UUIDProvider
    private let generateWallet: GenerateWalletProvider
    private let generateWrapper: GenerateWrapperProvider
    private let checksumProvider: (Data) -> String

    init(
        entropyService: RNGServiceAPI,
        walletEncoder: WalletEncodingAPI,
        encryptor: PayloadCryptoAPI,
        createWalletRepository: CreateWalletRepositoryAPI,
        uuidProvider: @escaping UUIDProvider,
        generateWallet: @escaping GenerateWalletProvider,
        generateWrapper: @escaping GenerateWrapperProvider,
        checksumProvider: @escaping (Data) -> String
    ) {
        self.uuidProvider = uuidProvider
        self.walletEncoder = walletEncoder
        self.encryptor = encryptor
        self.createWalletRepository = createWalletRepository
        self.entropyService = entropyService
        self.generateWallet = generateWallet
        self.generateWrapper = generateWrapper
        self.checksumProvider = checksumProvider
    }

    func createWallet(
        email: String,
        password: String,
        accountName: String,
        language: String = "en"
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
        .flatMap { [generateWallet, generateWrapper] context -> AnyPublisher<Wrapper, WalletCreateError> in
            generateWallet(context)
                .map { wallet -> Wrapper in
                    generateWrapper(wallet, language, WalletVersion.v4)
                }
                .publisher
                .eraseToAnyPublisher()
        }
        .flatMap { [walletEncoder, encryptor] wrapper -> AnyPublisher<EncodedWalletPayload, WalletCreateError> in
            walletEncoder.trasform(wrapper: wrapper)
                .mapError(WalletCreateError.encodingError)
                .flatMap { encodedPayload -> AnyPublisher<EncodedWalletPayload, WalletCreateError> in
                    guard case .encoded(let payload) = encodedPayload.payloadContext else {
                        return .failure(.expectedEncodedPayload)
                    }
                    guard let value = String(data: payload, encoding: .utf8) else {
                        return .failure(.genericFailure)
                    }
                    return encryptor.encrypt(data: value, with: password, pbkdf2Iterations: wrapper.pbkdf2Iterations)
                        .publisher
                        .mapError { _ in WalletCreateError.encryptionFailure }
                        .eraseToAnyPublisher()
                        .map { encryptedPayload in
                            EncodedWalletPayload(
                                payloadContext: .encrypted(Data(encryptedPayload.utf8)),
                                wrapper: wrapper
                            )
                        }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
        .flatMap { [walletEncoder, checksumProvider] payload -> AnyPublisher<WalletCreationPayload, WalletCreateError> in
            walletEncoder.encode(
                payload: payload,
                checksum: checksumProvider(payload.payloadContext.value),
                length: payload.payloadContext.value.count
            )
            .mapError(WalletCreateError.encodingError)
            .eraseToAnyPublisher()
        }
        .flatMap { [createWalletRepository] payload -> AnyPublisher<EmptyValue, WalletCreateError> in
            createWalletRepository.createWallet(email: email, payload: payload)
                .map { _ in .noValue }
                .mapError(WalletCreateError.networkError)
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
