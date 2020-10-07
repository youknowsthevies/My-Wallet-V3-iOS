//
//  DIKit.swift
//  BitcoinChainKit
//
//  Created by Jack Pooley on 05/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {
    
    // MARK: - BitcoinChainKit Module
     
    public static var bitcoinChainKit = module {
        
        // MARK: - Bitcoin

        factory(tag: BitcoinChainCoin.bitcoin) { APIClient(coin: .bitcoin) as APIClientAPI }
        
        factory(tag: BitcoinChainCoin.bitcoin) { BalanceService(coin: .bitcoin) as BalanceServiceAPI }
        
        // MARK: - Bitcoin Cash
        
        factory(tag: BitcoinChainCoin.bitcoinCash) { APIClient(coin: .bitcoinCash) as APIClientAPI }

        factory(tag: BitcoinChainCoin.bitcoinCash) { BalanceService(coin: .bitcoinCash) as BalanceServiceAPI }
    }
}
