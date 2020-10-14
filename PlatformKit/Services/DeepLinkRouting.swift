//
//  DeepLinkRouting.swift
//  PlatformKit
//
//  Created by Paulo on 13/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol DeepLinkRouting {

    /// Returns true if routing was performed
    func routeIfNeeded() -> Bool
}
