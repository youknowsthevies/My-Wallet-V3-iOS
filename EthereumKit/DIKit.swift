//
//  DIKit.swift
//  EthereumKit
//
//  Created by Jack Pooley on 24/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import NetworkKit

extension DependencyContainer {
    
    // MARK: - EthereumKit Module
     
    public static var ethereumKit = module {
        
        factory { APIClient() as APIClientAPI }
    }
}
