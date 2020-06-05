//
//  SwapServiceProvider.swift
//  Blockchain
//
//  Created by Alex McGregor on 4/28/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformKit

public protocol SwapServiceProviderAPI: class {
    var activity: SwapActivityService { get }
}

