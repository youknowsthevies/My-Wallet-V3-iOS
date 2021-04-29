// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Describes possible errors in the process of fetching an address
enum AddressFetchingError: Error {
    
    /// Fetching error
    case fetching
    
    /// Parsing error (into QR)
    case parsing
    
    /// Used address
    case alreadyUsed
    
    /// Address couldn't be found
    case absent
    
    /// Technical error - unretained self
    case unretainedSelf
}
