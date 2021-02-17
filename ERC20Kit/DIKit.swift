//
//  DIKit.swift
//  ERC20Kit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import ToolKit
import TransactionKit

extension DependencyContainer {

    // MARK: - ERC20Kit Module

    public static var erc20Kit = module {
        
        single(tag: Tags.ERC20AccountService.addressCache) {
            Atomic<[String: Bool]>([:])
        }
        
        // MARK: - PAX

        factory(tag: CryptoCurrency.pax) { ERC20Asset<PaxToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<PaxToken>() }
        
        factory(tag: CryptoCurrency.pax) { ERC20OnChainTransactionEngineFactory<PaxToken>() as OnChainTransactionEngineFactory }
        
        factory(tag: CryptoCurrency.pax) { ERC20ExternalAssetAddressFactory<PaxToken>() as CryptoReceiveAddressFactory }

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
        
        factory { ERC20AccountService<PaxToken>() }

        factory(tag: CryptoCurrency.pax) { ERC20AssetBalanceFetcher<PaxToken>() as CryptoAccountBalanceFetching }
        
        factory { AnyERC20HistoricalTransactionService<PaxToken>() }
        
        factory { ERC20Service<PaxToken>() }

        factory { () -> AnyERC20Service<PaxToken> in
            let service: ERC20Service<PaxToken> = DIKit.resolve()
            return AnyERC20Service<PaxToken>(service)
        }
        
        // MARK: - Tether

        factory(tag: CryptoCurrency.tether) { ERC20Asset<TetherToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<TetherToken>() }
        
        factory(tag: CryptoCurrency.tether) { ERC20OnChainTransactionEngineFactory<TetherToken>() as OnChainTransactionEngineFactory }
        
        factory(tag: CryptoCurrency.tether) { ERC20ExternalAssetAddressFactory<TetherToken>() as CryptoReceiveAddressFactory }

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
        
        factory { ERC20AccountService<TetherToken>() }

        factory(tag: CryptoCurrency.tether) { ERC20AssetBalanceFetcher<TetherToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<TetherToken>() }

        factory { ERC20Service<TetherToken>() }

        factory { () -> AnyERC20Service<TetherToken> in
            let service: ERC20Service<TetherToken> = DIKit.resolve()
            return AnyERC20Service<TetherToken>(service)
        }

        // MARK: - WDGLD

        factory(tag: CryptoCurrency.wDGLD) { ERC20Asset<WDGLDToken>() as CryptoAsset }

        factory { ERC20AssetAccountRepository<WDGLDToken>() }
        
        factory(tag: CryptoCurrency.wDGLD) { ERC20OnChainTransactionEngineFactory<WDGLDToken>() as OnChainTransactionEngineFactory }

        factory(tag: CryptoCurrency.wDGLD) { ERC20ExternalAssetAddressFactory<WDGLDToken>() as CryptoReceiveAddressFactory }

        factory(tag: CryptoCurrency.wDGLD) {
            AnyAssetAccountDetailsAPI(
                service: ERC20AssetAccountDetailsService<WDGLDToken>()
            )
        }

        factory { ERC20BalanceService<WDGLDToken>() }

        factory {
            AnyERC20AccountAPIClient<WDGLDToken>(
                accountAPIClient: ERC20AccountAPIClient<WDGLDToken>()
            )
        }

        factory { ERC20AccountAPIClient<WDGLDToken>() }
        
        factory { ERC20AccountService<WDGLDToken>() }

        factory(tag: CryptoCurrency.wDGLD) { ERC20AssetBalanceFetcher<WDGLDToken>() as CryptoAccountBalanceFetching }

        factory { AnyERC20HistoricalTransactionService<WDGLDToken>() }

        factory { ERC20Service<WDGLDToken>() }

        factory { () -> AnyERC20Service<WDGLDToken> in
            let service: ERC20Service<WDGLDToken> = DIKit.resolve()
            return AnyERC20Service<WDGLDToken>(service)
        }
    }
}

extension DependencyContainer {
    
    struct Tags {
        
        struct ERC20AccountService {
            
            static let addressCache = String(describing: Self.self)
        }
    }
}
