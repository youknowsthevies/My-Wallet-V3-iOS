//
//  SideMenuInteractor.swift
//  Blockchain
//
//  Created by Daniel Huri on 11/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift
import PlatformKit

final class SideMenuInteractor {
   
    var isSimpleBuyEnabled: Single<Bool> {
        simpleBuyEligibilityService.isEligible
            .catchErrorJustReturn(false)
    }
    
    private let dataRepository: BlockchainDataRepository
    private let simpleBuyEligibilityService: SimpleBuyEligibilityServiceAPI
   
    init(simpleBuyEligibilityService: SimpleBuyEligibilityServiceAPI = SimpleBuyServiceProvider.default.eligibility,
         dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared) {
        self.simpleBuyEligibilityService = simpleBuyEligibilityService
        self.dataRepository = dataRepository
    }
}
