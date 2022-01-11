// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import KeychainKit
import MetadataKit

enum WalletRepoKeychain {
    static let repoTag = "repo.tag"
}

enum WalletRepoOperationsQueue {
    static let queueTag = "op.queue.tag"
}

extension DependencyContainer {

    // MARK: - WalletPayloadKit Module

    public static var walletPayloadKit = module {

        single(tag: WalletRepoOperationsQueue.queueTag) { () -> DispatchQueue in
            DispatchQueue(label: "wallet.payload.operations.queue")
        }

        single { () -> WalletRepo in
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: WalletRepoKeychain.repoTag)
            let initialStateOrEmpty = retrieveWalletRepoState(keychainAccess: keychainAccess) ?? .empty
            return WalletRepo(initialState: initialStateOrEmpty)
        }

        single { () -> WalletRepoPersistenceAPI in
            let repo: WalletRepo = DIKit.resolve()
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.persistence.queue", qos: .default, target: targetQueue)
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: WalletRepoKeychain.repoTag)
            return WalletRepoPersistence(
                repo: repo,
                keychainAccess: keychainAccess,
                queue: queue
            )
        }

        factory { () -> WalletFetcherAPI in
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.fetching.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletFetcher(
                walletRepo: DIKit.resolve(),
                payloadCrypto: DIKit.resolve(),
                walletLogic: DIKit.resolve(),
                operationsQueue: queue
            )
        }

        factory { () -> WalletLogic in
            let walletCreator: WalletCreatorAPI = DIKit.resolve()
            let creator = walletCreator.createWallet(from:)
            return WalletLogic(
                holder: DIKit.resolve(),
                creator: creator,
                metadata: DIKit.resolve(),
                notificationCenter: .default
            )
        }

        factory { () -> WalletRecoveryServiceAPI in
            let walletLogic: WalletLogic = DIKit.resolve()
            let payloadCrypto: PayloadCryptoAPI = DIKit.resolve()
            let repo: WalletRepo = DIKit.resolve()
            let payloadRepository: WalletPayloadRepositoryAPI = DIKit.resolve()
            let targetQueue: DispatchQueue = DIKit.resolve(tag: WalletRepoOperationsQueue.queueTag)
            let queue = DispatchQueue(label: "wallet.recovery.op.queue", qos: .userInitiated, target: targetQueue)
            return WalletRecoveryService(
                walletLogic: walletLogic,
                payloadCrypto: payloadCrypto,
                walletRepo: repo,
                walletPayloadRepository: payloadRepository,
                operationsQueue: queue
            )
        }

        factory { () -> SecondPasswordServiceAPI in
            SecondPasswordService(walletHolder: DIKit.resolve())
        }

        factory { () -> WalletMetadataEntryServiceAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: MetadataServiceAPI = DIKit.resolve()
            return WalletMetadataEntryService(
                walletHolder: holder,
                metadataService: metadata
            )
        }

        factory { () -> UserCredentialsFetcherAPI in
            let metadataEntryService: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return UserCredentialsFetcher(
                metadataEntryService: metadataEntryService
            )
        }

        factory { () -> BitcoinCashEntryFetcherAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return BitcoinCashEntryFetcher(
                walletHolder: holder,
                metadataEntryService: metadata
            )
        }

        factory { () -> BitcoinEntryFetcherAPI in
            let holder: WalletHolderAPI = DIKit.resolve()
            let metadata: WalletMetadataEntryServiceAPI = DIKit.resolve()
            return BitcoinEntryFetcher(
                walletHolder: holder,
                metadataEntryService: metadata
            )
        }

        factory { MnemonicComponentsProvider() as MnemonicComponentsProviding }

        single(tag: WalletRepoKeychain.repoTag) { () -> KeychainAccessAPI in
            KeychainAccess(service: "com.blockchain.wallet-repo")
        }

        factory { WalletCryptoService() as WalletCryptoServiceAPI }

        factory { WalletPayloadCryptor() as WalletPayloadCryptorAPI }

        factory { PayloadCrypto() as PayloadCryptoAPI }

        factory { AESCryptor() as AESCryptorAPI }

        // MARK: Wallet Upgrade

        factory { WalletUpgradeService() as WalletUpgradeServicing }

        factory { WalletUpgradeJSService() as WalletUpgradeJSServicing }
    }
}
