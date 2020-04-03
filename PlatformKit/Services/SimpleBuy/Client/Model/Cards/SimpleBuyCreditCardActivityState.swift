//
//  SimpleBuyCreditCardActivityState.swift
//  PlatformKit
//
//  Created by Alex McGregor on 3/30/20.
//  Copyright © 2020 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation

public enum SimpleBuyCreditCardActivityState: String, Decodable {
    
    /// Initial state and updating of details is allowed
    case created = "CREATED"
    
    /// Card verified and ready for use
    case active = "ACTIVE"
    
    /// User has called `/add` and we are waiting for response from
    /// partner or user to complete verification
    case pending = "PENDING"
    
    /// Represents fraud review state
    case underReview = "UNDER_REVIEW"
    
    /// This card cannot be used (did not pass fraud review)
    case blocked = "BLOCKED"
}
