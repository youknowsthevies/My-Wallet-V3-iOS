//
//  ETHServiceProvider.swift
//  Blockchain
//
//  Created by Jack on 26/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import EthereumKit

final class ETHServiceProvider {

    static let shared: ETHServiceProvider = .init(services: .init())
    
    let services: ETHServices
    
    init(services: ETHServices) {
        self.services = services
    }
    
    var repository: EthereumWalletAccountRepository {
        services.repository
    }
    
    var assetAccountRepository: EthereumAssetAccountRepository {
        services.assetAccountRepository
    }
    
    var transactionService: EthereumHistoricalTransactionService {
        services.transactionService
    }
}
