//
//  AddCardServiceProvider.swift
//  Blockchain
//
//  Created by Daniel Huri on 02/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

final class AddCardServiceProvider {
    
    let dataRepository: DataRepositoryAPI
    
    init(dataRepository: DataRepositoryAPI = BlockchainDataRepository.shared) {
        self.dataRepository = dataRepository
    }
}
