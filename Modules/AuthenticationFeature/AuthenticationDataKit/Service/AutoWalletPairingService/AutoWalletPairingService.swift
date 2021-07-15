// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import DIKit
import RxSwift
import ToolKit
import WalletPayloadKit

/// A service that is responsible for the auto pairing process
public final class AutoWalletPairingService: AutoWalletPairingServiceAPI {

    // MARK: - Type

    public typealias WalletRepositoryAPI = GuidRepositoryAPI &
        SessionTokenRepositoryAPI &
        SharedKeyRepositoryAPI &
        LanguageRepositoryAPI &
        SyncPubKeysRepositoryAPI &
        AuthenticatorRepositoryAPI &
        PayloadRepositoryAPI

    // MARK: - Properties

    private let walletCryptoService: WalletCryptoServiceAPI
    private let parsingService = SharedKeyParsingService()

    private let walletPairingClient: AutoWalletPairingClientAPI
    private let walletPayloadService: WalletPayloadServiceAPI

    // MARK: - Setup

    public init(repository: WalletRepositoryAPI,
                walletPayloadClient: WalletPayloadClientAPI = resolve(),
                walletPairingClient: AutoWalletPairingClientAPI = resolve(),
                walletCryptoService: WalletCryptoServiceAPI = resolve()) {
        self.walletPairingClient = walletPairingClient
        self.walletPayloadService = WalletPayloadService(
            client: walletPayloadClient,
            repository: repository
        )
        self.walletCryptoService = walletCryptoService
    }

    /// Maps a QR pairing code of a wallet into its password, retrieve and cache the wallet data.
    /// Finally returns the password of the wallet
    /// 1. Receives a pairing code (guid, encrypted shared-key)
    /// 2. Sends the wallet `guid` -> receives a passphrase that can be used to decrypt the shared key.
    /// 3. Decrypt the shared key
    /// 4. Parse the shared key and the password
    /// 5. Request the wallet payload using the wallet GUID and the shared key
    /// 6. Returns the password.
    /// - Parameter pairingData: A pairing code comprises GUID and an encrypted shared key.
    /// - Returns: The wallet password - decrypted and ready for usage.
    public func pair(using pairingData: PairingData) -> Single<String> {
        walletPairingClient.request(guid: pairingData.guid)
            .map { KeyDataPair<String, String>(key: $0, data: pairingData.encryptedSharedKey) }
            .flatMap(weak: self) { (self, keyDataPair) -> Single<String> in
                self.walletCryptoService.decrypt(pair: keyDataPair, pbkdf2Iterations: WalletCryptoPBKDF2Iterations.autoPair)
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .map(parsingService.parse)
            .flatMap(weak: self) { (self, pair) in
                self.walletPayloadService.request(
                    guid: pairingData.guid,
                    sharedKey: pair.data
                )
                .andThen(.just(pair.key))
            }
    }

    public func encryptionPhrase(using guid: String) -> Single<String> {
        walletPairingClient.request(guid: guid)
    }
}
