// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import ToolKit
import TransactionKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {

        // MARK: Asset Agnostic

        single(tag: Tags.ERC20AccountService.isContractAddressCache) {
            Atomic<[String: Bool]>([:])
        }

        factory(tag: ERC20AssetModel.typeTag) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        factory { ERC20AssetFactory() as ERC20AssetFactoryAPI }

        factory { ERC20HistoricalTransactionService() as ERC20HistoricalTransactionServiceAPI }

        factory { ERC20AccountDetailsService() as ERC20AccountDetailsServiceAPI }

        factory { ERC20BalanceService() as ERC20BalanceServiceAPI }

        factory { ERC20AccountAPIClient() as ERC20AccountAPIClientAPI }

        factory { ERC20AccountService() as ERC20AccountServiceAPI }

    }
}

extension DependencyContainer {
    enum Tags {
        enum ERC20AccountService {
            static let isContractAddressCache = String(describing: Self.self)
        }
    }
}
