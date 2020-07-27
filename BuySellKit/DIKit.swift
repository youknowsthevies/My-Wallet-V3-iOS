//
//  DIKit.swift
//  BuySellKit
//
//  Created by Jack Pooley on 25/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    // MARK: - BuySellKit Module
     
    public static var buySellKit = module {
        
        factory { APIClient() as SimpleBuyClientAPI }
        
        factory { CardClient() as CardClientAPI }
        
        factory { EveryPayClient() as EveryPayClientAPI }
    }
}
