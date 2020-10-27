//
//  DIKit.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {

        // MARK: - PAX

        factory(tag: CryptoCurrency.pax) { ERC20Asset<PaxToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<PaxToken>() }

        factory(tag: CryptoCurrency.pax) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<PaxToken>()
            )
        }

        factory { ERC20BalanceService<PaxToken>() }

        factory {
            AnyERC20AccountAPIClient<PaxToken>(
                accountAPIClient: ERC20AccountAPIClient<PaxToken>()
            )
        }

        factory { ERC20AccountAPIClient<PaxToken>() }

        factory(tag: CryptoCurrency.pax) { ERC20AssetBalanceFetcher<PaxToken>() as CryptoAccountBalanceFetching }
        
        factory { AnyERC20HistoricalTransactionService<PaxToken>() }
        
        factory { ERC20Service<PaxToken>() }
        
        // MARK: - Tether

        factory(tag: CryptoCurrency.tether) { ERC20Asset<TetherToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<TetherToken>() }

        factory(tag: CryptoCurrency.tether) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<TetherToken>()
            )
        }

        factory { ERC20BalanceService<TetherToken>() }

        factory {
            AnyERC20AccountAPIClient<TetherToken>(
                accountAPIClient: ERC20AccountAPIClient<TetherToken>()
            )
        }

        factory { ERC20AccountAPIClient<TetherToken>() }

        factory(tag: CryptoCurrency.tether) { ERC20AssetBalanceFetcher<TetherToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<TetherToken>() }

    }
}
