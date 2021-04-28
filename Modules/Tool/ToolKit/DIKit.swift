//
//  DIKit.swift
//  ToolKit
//
//  Created by Jack Pooley on 24/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit

extension DependencyContainer {
    
    // MARK: - ToolKit Module
     
    public static var toolKit = module {
        
        factory { UserDefaults.standard as CacheSuite }
    }
}
