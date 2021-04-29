// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxRelay
import RxSwift

/// Deals with the source account interaction on the send flow.
final class SendSourceAccountInteractor: SendSourceAccountInteracting {
    
    // MARK: - Exposed Properties
    
    /// Streams the *selected* source account to send crypto from
    var account: Observable<SendSourceAccount> {
        accountRelay.asObservable()
    }
    
    /// Streams the state of the account
    var state: Observable<SendSourceAccountState> {
        stateService.state
    }
    
    // MARK: - Private Properties
    
    /// The source account to send crypto from
    private let accountRelay: BehaviorRelay<SendSourceAccount>
    
    private let stateService: SendSourceAccountStateServicing
    private let provider: SendSourceAccountProviding
    
    // MARK: - Setup
    
    init(provider: SendSourceAccountProviding,
         stateService: SendSourceAccountStateServicing) {
        self.provider = provider
        self.stateService = stateService
        accountRelay = BehaviorRelay(value: provider.default)
    }
}
