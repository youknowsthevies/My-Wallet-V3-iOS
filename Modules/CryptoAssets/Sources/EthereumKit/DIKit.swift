// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import MoneyKit
import PlatformKit
import ToolKit

extension DependencyContainer {

    // MARK: - EthereumKit Module

    public static var ethereumKit = module {

        // MARK: APIClient

        factory { APIClient() as TransactionPushClientAPI }

        factory { APIClient() as TransactionClientAPI }

        factory { APIClient() as TransactionFeeClientAPI }

        // MARK: RPCClient

        factory { RPCClient() as LatestBlockClientAPI }

        factory { RPCClient() as EstimateGasClientAPI }

        factory { RPCClient() as GetTransactionCountClientAPI }

        factory { RPCClient() as GetBalanceClientAPI }

        factory { RPCClient() as GetCodeClientAPI }

        // MARK: CoinCore

        factory(tag: CryptoCurrency.ethereum) { EthereumAsset() as CryptoAsset }

        // MARK: Other

        single { EthereumNonceRepository() as EthereumNonceRepositoryAPI }

        single { EthereumBalanceRepository() as EthereumBalanceRepositoryAPI }

        single { EthereumWalletAccountRepository() as EthereumWalletAccountRepositoryAPI }

        single { EthereumHistoricalTransactionService() as EthereumHistoricalTransactionServiceAPI }

        factory { () -> AnyActivityItemEventDetailsFetcher<EthereumActivityItemEventDetails> in
            AnyActivityItemEventDetailsFetcher(api: EthereumActivityItemEventDetailsFetcher())
        }

        factory { EthereumTransactionBuildingService() as EthereumTransactionBuildingServiceAPI }

        factory { EthereumTransactionSendingService() as EthereumTransactionSendingServiceAPI }

        factory { EthereumTransactionSigningService() as EthereumTransactionSigningServiceAPI }

        factory { EthereumFeeService() as EthereumFeeServiceAPI }

        factory { EthereumAccountService() as EthereumAccountServiceAPI }

        factory { EthereumKeyPairProvider() }

        factory { AnyKeyPairProvider<EthereumKeyPair>.ethereum() }

        factory { EthereumSigner() as EthereumSignerAPI }

        factory { EthereumTransactionDispatcher() as EthereumTransactionDispatcherAPI }

        single(tag: Tags.EthereumAccountService.isContractAddressCache) {
            Atomic<[String: Bool]>([:])
        }

        factory { WalletConnectEngineFactory() as WalletConnectEngineFactoryAPI }

        factory { GasEstimateService() as GasEstimateServiceAPI }
    }
}

extension DependencyContainer {
    enum Tags {
        enum EthereumAccountService {
            static let isContractAddressCache = String(describing: Self.self)
        }
    }
}

extension AnyKeyPairProvider where Pair == EthereumKeyPair {

    fileprivate static func ethereum(
        ethereumKeyPairProvider: EthereumKeyPairProvider = resolve()
    ) -> AnyKeyPairProvider<Pair> {
        AnyKeyPairProvider<Pair>(provider: ethereumKeyPairProvider)
    }
}
