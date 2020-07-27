//
//  NonCustodialActionState.swift
//  Blockchain
//
//  Created by AlexM on 2/27/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum NonCustodialActionState {
    
    /// Display action screen
    case actions
    
    /// Route to Swap
    case swap
    
    /// Route to activity
    case activity
    
    /// Route to send
    case send
    
    /// Route to receive
    case receive
}
