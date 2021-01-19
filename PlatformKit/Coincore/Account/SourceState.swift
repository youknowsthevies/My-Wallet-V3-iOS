//
//  SourceState.swift
//  PlatformKit
//
//  Created by Paulo on 30/07/2020.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

public enum SourceState {
    case canSend
    case noFunds
    case fundsLocked
    case notEnoughGas
    case sendInFlight
    case notSupported
}
