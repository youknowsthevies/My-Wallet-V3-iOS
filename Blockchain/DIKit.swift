//
//  DIKit.swift
//  Blockchain
//
//  Created by Paulo on 17/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import ToolKit
import PlatformKit
import PlatformUIKit

extension DependencyContainer {
    
    // MARK: - Blockchain Module
    
    static var blockchain = module {
        single { EnabledCurrenciesService(featureFetcher: AppFeatureConfigurator.shared) }
    }
}
