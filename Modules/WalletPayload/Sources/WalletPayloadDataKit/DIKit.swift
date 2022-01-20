// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import KeychainKit
import NetworkKit
import WalletPayloadKit

enum WalletRepoKeychain {
    static let repoTag = "repo.tag"
    static let walletServer = "wallet.server"
}

extension DependencyContainer {

    // MARK: - walletPayloadDataKit Module

    public static var walletPayloadDataKit = module {

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        factory { WalletPayloadRepository() as WalletPayloadRepositoryAPI }

        factory(tag: WalletRepoKeychain.walletServer) {
            RequestBuilder(
                config: Network.Config(
                    scheme: "https",
                    host: "api.blockchain.info",
                    code: "35e77459-723f-48b0-8c9e-6e9e8f54fbd3",
                    components: []
                )
            )
        }

        factory { () -> ServerEntropyClientAPI in
            ServerEntropyClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: WalletRepoKeychain.walletServer)
            )
        }

        factory { () -> ServerEntropyRepositoryAPI in
            ServerEntropyRepository(
                client: DIKit.resolve()
            )
        }

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
