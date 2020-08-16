//
//  Other.swift
//  PlatformKit
//
//  Created by Paulo on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public protocol SendProcessor {
    
}

public enum SendState {
    case canSend
    case noFunds
    case notEnoughGas
    case sendInFlight
    case notSupported
}
