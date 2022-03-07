// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
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
        bridge: StellarWalletBridgeAPI = resolve(),
        metadataEntryService: WalletMetadataEntryServiceAPI = resolve(),
        mnemonicAccessAPI: MnemonicAccessAPI = resolve(),
        nativeWalletEnabled: @escaping () -> AnyPublisher<Bool, Never> = { nativeWalletFlagEnabled() }
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
        let save_old = loadKeyPair()
            .flatMap { keyPair -> AnyPublisher<StellarKeyPair, StellarWalletAccountRepositoryError> in
                saveKeyPair(keyPair)
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

        return nativeWalletFlagEnabled()
            .flatMap { isEnabled -> AnyPublisher<WalletAccount, StellarWalletAccountRepositoryError> in
                guard isEnabled else {
                    return save_old
                        .eraseToAnyPublisher()
                }
                #warning("saving on native wallet is not yet supported")
                return .failure(StellarWalletAccountRepositoryError.saveFailure)
                    .crashOnError()
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
