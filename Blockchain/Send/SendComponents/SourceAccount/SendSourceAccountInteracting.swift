// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

/// The interaction protocol for the source account on the send flow.
protocol SendSourceAccountInteracting {
    
    /// The source account to send crypto from
    var account: Observable<SendSourceAccount> { get }
    
    /// The source account state
    var state: Observable<SendSourceAccountState> { get }
}
