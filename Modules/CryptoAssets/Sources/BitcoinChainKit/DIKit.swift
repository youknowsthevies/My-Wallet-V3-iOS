// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit

extension DependencyContainer {

    // MARK: - BitcoinChainKit Module

    public static var bitcoinChainKit = module {

        // MARK: - Bitcoin

        factory(tag: BitcoinChainCoin.bitcoin) {
            BitcoinChainKit.APIClient(coin: .bitcoin) as BitcoinChainKit.APIClientAPI
        }

        factory(tag: BitcoinChainCoin.bitcoin) { () -> UnspentOutputRepositoryAPI in
            UnspentOutputRepository(
                client: DIKit.resolve(tag: BitcoinChainCoin.bitcoin)
            )
        }

        factory(tag: BitcoinChainCoin.bitcoin) { () -> BitcoinTransactionSigningServiceAPI in
            BitcoinTransactionSigningService()
        }

        factory(tag: BitcoinChainCoin.bitcoin) { () -> BitcoinTransactionSendingServiceAPI in
            BitcoinTransactionSendingService()
        }

        factory(tag: BitcoinChainCoin.bitcoin) { () -> BitcoinTransactionBuildingServiceAPI in
            BitcoinTransactionBuildingService(
                unspentOutputRepository: DIKit.resolve(tag: BitcoinChainCoin.bitcoin),
                coinSelection: DIKit.resolve()
            )
        }

        single(tag: BitcoinChainCoin.bitcoin) { BalanceService(coin: .bitcoin) as BalanceServiceAPI }

        factory(tag: BitcoinChainCoin.bitcoin) {
            AnyCryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>>.bitcoin()
        }

        factory(tag: BitcoinChainCoin.bitcoin) {
            BitcoinChainExternalAssetAddressFactory<BitcoinToken>() as ExternalAssetAddressFactory
        }

        factory { CryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>>() }

        // MARK: - Bitcoin Cash

        factory(tag: BitcoinChainCoin.bitcoinCash) {
            BitcoinChainKit.APIClient(coin: .bitcoinCash) as BitcoinChainKit.APIClientAPI
        }

        factory(tag: BitcoinChainCoin.bitcoinCash) { () -> UnspentOutputRepositoryAPI in
            UnspentOutputRepository(
                client: DIKit.resolve(tag: BitcoinChainCoin.bitcoinCash)
            )
        }

        factory(tag: BitcoinChainCoin.bitcoinCash) { () -> BitcoinTransactionSigningServiceAPI in
            BitcoinTransactionSigningService()
        }

        factory(tag: BitcoinChainCoin.bitcoinCash) { () -> BitcoinTransactionSendingServiceAPI in
            BitcoinTransactionSendingService()
        }

        factory(tag: BitcoinChainCoin.bitcoinCash) { () -> BitcoinTransactionBuildingServiceAPI in
            BitcoinTransactionBuildingService(
                unspentOutputRepository: DIKit.resolve(tag: BitcoinChainCoin.bitcoinCash),
                coinSelection: DIKit.resolve()
            )
        }

        single(tag: BitcoinChainCoin.bitcoinCash) { BalanceService(coin: .bitcoinCash) as BalanceServiceAPI }

        factory(tag: BitcoinChainCoin.bitcoinCash) {
            AnyCryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>>.bitcoinCash()
        }

        factory(tag: BitcoinChainCoin.bitcoinCash) {
            BitcoinChainExternalAssetAddressFactory<BitcoinCashToken>() as ExternalAssetAddressFactory
        }

        factory { CryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>>() }

        // MARK: - Asset Agnostic

        factory { CoinSelection() as CoinSelector }
    }
}

extension AnyCryptoFeeService where FeeType == BitcoinChainTransactionFee<BitcoinToken> {
    fileprivate static func bitcoin(
        service: CryptoFeeService<BitcoinChainTransactionFee<BitcoinToken>> = resolve()
    ) -> AnyCryptoFeeService<FeeType> {
        AnyCryptoFeeService<FeeType>(service: service)
    }
}

extension AnyCryptoFeeService where FeeType == BitcoinChainTransactionFee<BitcoinCashToken> {
    fileprivate static func bitcoinCash(
        service: CryptoFeeService<BitcoinChainTransactionFee<BitcoinCashToken>> = resolve()
    ) -> AnyCryptoFeeService<FeeType> {
        AnyCryptoFeeService<FeeType>(service: service)
    }
}
