// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import KeychainKit
import NetworkKit
import ToolKit
import WalletPayloadKit

enum DIKitWalletPayloadTags {
    static let repoTag = "repo.tag"
    static let walletServer = "wallet.server"
}

extension DependencyContainer {

    // MARK: - walletPayloadDataKit Module

    public static var walletPayloadDataKit = module {

        factory { WalletPayloadClient() as WalletPayloadClientAPI }

        factory { WalletPayloadRepository() as WalletPayloadRepositoryAPI }

        factory(tag: DIKitWalletPayloadTags.walletServer) {
            RequestBuilder.walletServerBuilder()
        }

        factory { () -> ServerEntropyClientAPI in
            ServerEntropyClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: DIKitWalletPayloadTags.walletServer)
            )
        }

        factory { () -> ServerEntropyRepositoryAPI in
            ServerEntropyRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> CreateWalletClientAPI in
            CreateWalletClient(
                networkAdapter: DIKit.resolve(),
                requestBuilder: DIKit.resolve(tag: DIKitWalletPayloadTags.walletServer)
            )
        }

        factory { () -> CreateWalletRepositoryAPI in
            CreateWalletRepository(
                client: DIKit.resolve()
            )
        }

        factory { () -> WalletDecoderAPI in
            WalletDecoder() as WalletDecoderAPI
        }

        factory { () -> WalletEncodingAPI in
            WalletEncoder() as WalletEncodingAPI
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
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: DIKitWalletPayloadTags.repoTag)
            let initialStateOrEmpty = retrieveWalletRepoState(keychainAccess: keychainAccess) ?? .empty
            return WalletRepo(initialState: initialStateOrEmpty)
        }

        single { () -> WalletRepoPersistenceAPI in
            let repo: WalletRepoAPI = DIKit.resolve()
            let queue = DispatchQueue(label: "wallet.persistence.queue", qos: .default)
            let keychainAccess: KeychainAccessAPI = DIKit.resolve(tag: DIKitWalletPayloadTags.repoTag)
            return WalletRepoPersistence(
                repo: repo,
                keychainAccess: keychainAccess,
                queue: queue
            )
        }

        single(tag: DIKitWalletPayloadTags.repoTag) { () -> KeychainAccessAPI in
            KeychainAccess(service: "com.blockchain.wallet-repo")
        }
    }
}

extension WalletPayloadData.Config {
    fileprivate static func `default`(
        code: APICode = resolve()
    ) -> WalletPayloadData.Config {
        WalletPayloadData.Config(
            host: InfoDictionaryHelper.value(for: .apiURL),
            code: code
        )
    }
}

extension WalletPayloadData.Config {
    fileprivate static func walletServer(
        config: WalletPayloadData.Config = .default()
    ) -> Network.Config {
        Network.Config(
            scheme: "https",
            host: config.host,
            code: config.code,
            components: []
        )
    }
}

extension RequestBuilder {

    fileprivate static func walletServerBuilder(
    ) -> RequestBuilder {
        RequestBuilder(
            config: WalletPayloadData.Config.walletServer()
        )
    }
}
