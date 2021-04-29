// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// The state of the source account
enum SendSourceAccountState {
    
    /// The account is waiting on transaction completion
    /// and cannot execute another one at the moment
    case pendingTransactionCompletion
    
    /// The account is valid to send a transaction
    case available
    
    /// Calculating the account state
    case calculating
    
    /// Is the value of self `true`
    var isCalculating: Bool {
        self == .calculating
    }
}
