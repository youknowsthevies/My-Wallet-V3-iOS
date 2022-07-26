// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import MetadataKit
import MoneyKit
import PlatformKit
import ToolKit
import WalletPayloadKit

public enum StellarWalletAccountRepositoryError: Error {
    case missingWallet
    case saveFailure
    case mnemonicFailure(MnemonicAccessError)
    case metadataFetchError(WalletAssetFetchError)
    case failedToDeriveInput(Error)
    case failedToFetchAccount(Error)
}

public protocol StellarWalletAccountRepositoryAPI {
    var defaultAccount: AnyPublisher<StellarWalletAccount?, StellarWalletAccountRepositoryError> { get }

    func initializeMetadataMaybe() -> AnyPublisher<StellarWalletAccount, StellarWalletAccountRepositoryError>
    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError>
    func loadKeyPair(with secondPassword: String?) -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError>
}

final class StellarWalletAccountRepository: StellarWalletAccountRepositoryAPI {
    typealias WalletAccount = StellarWalletAccount

    private struct Key: Hashable {}

    /// The default `StellarWallet`, will be nil if it has not yet been initialized
    var defaultAccount: AnyPublisher<StellarWalletAccount?, StellarWalletAccountRepositoryError> {
        accounts
            .map(\.first)
            .eraseToAnyPublisher()
    }

    private let accounts: AnyPublisher<[StellarWalletAccount], StellarWalletAccountRepositoryError>

    private let bridge: StellarWalletBridgeAPI
    private let metadataEntryService: WalletMetadataEntryServiceAPI
    private let mnemonicAccessAPI: MnemonicAccessAPI
    private let nativeWalletEnabled: () -> AnyPublisher<Bool, Never>

    private let cachedValue: CachedValueNew<
        Key,
        [StellarWalletAccount],
        StellarWalletAccountRepositoryError
    >

    private let deriver = StellarKeyPairDeriver()

    init(
        bridge: StellarWalletBridgeAPI,
        metadataEntryService: WalletMetadataEntryServiceAPI,
        mnemonicAccessAPI: MnemonicAccessAPI,
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never>
    ) {
        self.bridge = bridge
        self.metadataEntryService = metadataEntryService
        self.mnemonicAccessAPI = mnemonicAccessAPI
        self.nativeWalletEnabled = nativeWalletEnabled

        let cache: AnyCache<Key, [StellarWalletAccount]> = InMemoryCache(
            configuration: .onLoginLogout(),
            refreshControl: PerpetualCacheRefreshControl()
        ).eraseToAnyCache()

        let fetch_old = { [bridge] () -> AnyPublisher<[StellarWalletAccount], StellarWalletAccountRepositoryError> in
            Deferred {
                Future { promise in
                    let wallets = bridge.stellarWallets()
                    promise(.success(wallets))
                }
            }
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        }

        let fetch_new = { () -> AnyPublisher<[StellarWalletAccount], StellarWalletAccountRepositoryError> in
            metadataEntryService.fetchEntry(type: StellarEntryPayload.self)
                .map(\.accounts)
                .catch { error -> AnyPublisher<[StellarEntryPayload.Account], WalletAssetFetchError> in
                    guard case .fetchFailed(.loadMetadataError(.notYetCreated)) = error else {
                        return .failure(error)
                    }
                    // TODO: Refactor this once we remove JS, we shouldn't rely on emptiness
                    return .just([])
                }
                .map { accounts in
                    accounts.enumerated().map { index, account in
                        StellarWalletAccount(
                            index: index,
                            publicKey: account.publicKey,
                            label: account.label,
                            archived: account.archived
                        )
                    }
                }
                .mapError(StellarWalletAccountRepositoryError.metadataFetchError)
                .eraseToAnyPublisher()
        }

        cachedValue = CachedValueNew(
            cache: cache,
            fetch: { [nativeWalletEnabled] _ in
                nativeWalletEnabled()
                    .flatMap { isEnabled -> AnyPublisher<[StellarWalletAccount], StellarWalletAccountRepositoryError> in
                        guard isEnabled else {
                            return fetch_old()
                        }
                        return fetch_new()
                    }
                    .eraseToAnyPublisher()
            }
        )

        accounts = cachedValue.get(key: Key())
    }

    func initializeMetadataMaybe() -> AnyPublisher<WalletAccount, StellarWalletAccountRepositoryError> {
        let createAndSave = createAndSaveStellarAccount
        return defaultAccount
            .flatMap { account -> AnyPublisher<WalletAccount, StellarWalletAccountRepositoryError> in
                guard let account = account else {
                    return createAndSave().eraseToAnyPublisher()
                }
                return .just(account)
            }
            .eraseToAnyPublisher()
    }

    func loadKeyPair(
        with secondPassword: String?
    ) -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        mnemonicAccessAPI
            .mnemonic(with: secondPassword)
            .mapError(StellarWalletAccountRepositoryError.mnemonicFailure)
            .map { mnemonic in
                StellarKeyDerivationInput(mnemonic: mnemonic)
            }
            .flatMap { [deriver] input -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> in
                derive(input: input, deriver: deriver)
            }
            .eraseToAnyPublisher()
    }

    func loadKeyPair() -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
        mnemonicAccessAPI
            .mnemonicPromptingIfNeeded
            .mapError(StellarWalletAccountRepositoryError.mnemonicFailure)
            .map { mnemonic in
                StellarKeyDerivationInput(mnemonic: mnemonic)
            }
            .flatMap { [deriver] input -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> in
                derive(input: input, deriver: deriver)
            }
            .eraseToAnyPublisher()
    }

    // MARK: Private

    private func createAndSaveStellarAccount() -> AnyPublisher<WalletAccount, StellarWalletAccountRepositoryError> {
        let saveKeyPair = save

        return loadKeyPair()
            .flatMap { [metadataEntryService] keyPair
                -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> in
                nativeWalletFlagEnabled()
                    .flatMap { isEnabled -> AnyPublisher<StellarKeyPair, StellarAccountError> in
                        guard isEnabled else {
                            return saveKeyPair(keyPair)
                        }
                        return saveNatively(
                            metadataEntryService: metadataEntryService,
                            keyPair: keyPair
                        )
                    }
                    .mapError { _ in StellarWalletAccountRepositoryError.saveFailure }
                    .eraseToAnyPublisher()
            }
            .map { keyPair -> WalletAccount in
                WalletAccount(
                    index: 0,
                    publicKey: keyPair.accountID,
                    label: CryptoCurrency.stellar.defaultWalletName,
                    archived: false
                )
            }
            .eraseToAnyPublisher()
    }

    private func save(keyPair: StellarKeyPair) -> AnyPublisher<StellarKeyPair, StellarAccountError> {
        Deferred { [bridge] in
            Future { promise in
                bridge.save(
                    keyPair: keyPair,
                    label: CryptoCurrency.stellar.defaultWalletName,
                    completion: { result in
                        switch result {
                        case .success:
                            promise(.success(keyPair))
                        case .failure:
                            promise(.failure(StellarAccountError.unableToSaveNewAccount))
                        }
                    }
                )
            }
        }
        .subscribe(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

private func saveNatively(
    metadataEntryService: WalletMetadataEntryServiceAPI,
    keyPair: StellarKeyPair
) -> AnyPublisher<StellarKeyPair, StellarAccountError> {
    let account = StellarEntryPayload.Account(
        archived: false,
        label: CryptoCurrency.stellar.defaultWalletName,
        publicKey: keyPair.accountID
    )
    let payload = StellarEntryPayload(
        accounts: [account],
        defaultAccountIndex: 0,
        txNotes: [:]
    )
    return metadataEntryService.save(node: payload)
        .mapError { _ in StellarAccountError.unableToSaveNewAccount }
        .map { _ in keyPair }
        .eraseToAnyPublisher()
}

private func derive(
    input: StellarKeyDerivationInput,
    deriver: StellarKeyPairDeriver
) -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> {
    Deferred {
        Future { promise in
            switch deriver.derive(input: input) {
            case .success(let success):
                promise(.success(success))
            case .failure(let error):
                promise(.failure(StellarWalletAccountRepositoryError.failedToDeriveInput(error)))
            }
        }
    }
    .eraseToAnyPublisher()
}
