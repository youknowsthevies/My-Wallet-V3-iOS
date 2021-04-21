//
//  DIKit.swift
//  InterestKit
//
//  Created by Paulo on 07/08/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - InterestKit Module

    public static var interestKit = module {
        factory { SavingsAccountClient() as SavingsAccountClientAPI }

        factory { SavingAccountService() as SavingAccountServiceAPI }
        
        factory { SavingAccountService() as SavingsOverviewAPI }
    }
}
