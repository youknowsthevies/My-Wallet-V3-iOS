//
//  DIKit.swift
//  BitcoinKit
//
//  Created by Jack Pooley on 25/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    // MARK: - BitcoinKit Module
     
    public static var bitcoinKit = module {
        
        factory { APIClient() as APIClientAPI }
    }
}
