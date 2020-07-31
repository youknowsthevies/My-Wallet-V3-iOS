//
//  CardServiceProviderAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 08/04/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol CardServiceProviderAPI: class {
        
    var cardList: CardListServiceAPI { get }
    var cardDeletion: PaymentMethodDeletionServiceAPI { get }
    var cardUpdate: CardUpdateServiceAPI { get }
    
    /// This service is computed and is not kept as instance property of the provider
    var cardActivation: CardActivationServiceAPI { get }
    
    var dataRepository: DataRepositoryAPI { get }
}
