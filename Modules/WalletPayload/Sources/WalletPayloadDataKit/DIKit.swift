// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import KeychainKit
import WalletPayloadKit

enum WalletRepoKeychain {
    static let repoTag = "repo.tag"
}

extension DependencyContainer {

    // MARK: - walletPayloadDataKit Module

    public static var walletPayloadDataKit = module {

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        factory { WalletPayloadRepository() as WalletPayloadRepositoryAPI }

        factory { () -> WalletCreatorAPI in
            WalletCreator() as WalletCreatorAPI
        }

        factory { () -> ReleasableWalletAPI in
            let holder: WalletHolder = DIKit.resolve()
            return holder as ReleasableWalletAPI
        }

        factory { () -> WalletHolderAPI in
            let holder: WalletHolder = DIKit.resolve()
            return holder as WalletHolderAPI
        }

        single { WalletHolder() }

        single { () -> WalletRepoAPI in
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: WalletRepoKeychain.repoTag)
            let initialStateOrEmpty = retrieveWalletRepoState(keychainAccess: keychainAccess) ?? .empty
            return WalletRepo(initialState: initialStateOrEmpty)
        }

        single { () -> WalletRepoPersistenceAPI in
            let repo: WalletRepoAPI = DIKit.resolve()
            let queue = DispatchQueue(label: "wallet.persistence.queue", qos: .default)
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: WalletRepoKeychain.repoTag)
            return WalletRepoPersistence(
                repo: repo,
                keychainAccess: keychainAccess,
                queue: queue
            )
        }

        single(tag: WalletRepoKeychain.repoTag) { () -> KeychainAccessAPI in
            KeychainAccess(service: "com.blockchain.wallet-repo")
        }
    }
}
