//
//  SimpleBuyEligibilityClientAPI.swift
//  PlatformKit
//
//  Created by Daniel Huri on 14/02/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol SimpleBuyEligibilityClientAPI: class {
    
    /// Streams a boolean value indicating whether the user can or cannot trade
    func isEligible(for currency: String,
                    methods: [String],
                    token: String) -> Single<SimpleBuyEligibilityResponse>
}
