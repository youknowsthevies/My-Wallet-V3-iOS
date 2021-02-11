//
//  InternalFeature.swift
//  DebugUIKit
//
//  Created by Dimitrios Chatzieleftheriou on 23/10/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {
    case oldSwap
    case sendP2
    case swapP2
    case achFlow

    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }
}
