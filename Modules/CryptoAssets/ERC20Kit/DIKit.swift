// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import ToolKit
import TransactionKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {

        // MARK: - Aave

        factory(tag: CryptoCurrency.erc20(.aave)) { ERC20Asset(erc20Token: ERC20Token.aave) as CryptoAsset }

        factory(tag: CryptoCurrency.erc20(.aave)) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        // MARK: - PAX

        factory(tag: CryptoCurrency.erc20(.pax)) { ERC20Asset(erc20Token: ERC20Token.pax) as CryptoAsset }

        factory(tag: CryptoCurrency.erc20(.pax)) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        // MARK: - Tether

        factory(tag: CryptoCurrency.erc20(.tether)) { ERC20Asset(erc20Token: ERC20Token.tether) as CryptoAsset }

        factory(tag: CryptoCurrency.erc20(.tether)) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        // MARK: - WDGLD

        factory(tag: CryptoCurrency.erc20(.wdgld)) { ERC20Asset(erc20Token: ERC20Token.wdgld) as CryptoAsset }

        factory(tag: CryptoCurrency.erc20(.wdgld)) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        // MARK: - Yearn Finance

        factory(tag: CryptoCurrency.erc20(.yearnFinance)) { ERC20Asset(erc20Token: ERC20Token.yearnFinance) as CryptoAsset }

        factory(tag: CryptoCurrency.erc20(.yearnFinance)) { ERC20ExternalAssetAddressFactory() as CryptoReceiveAddressFactory }

        // MARK: Asset Agnostic

        single(tag: Tags.ERC20AccountService.isContractAddressCache) {
            Atomic<[String: Bool]>([:])
        }

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
