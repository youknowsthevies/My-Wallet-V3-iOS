// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

/// Content for wallet registration (creation / recovery)
struct WalletRegistrationContent {
    var email = ""
    var password = ""
}

protocol RegisterWalletScreenInteracting: AnyObject {

    /// Content relay
    var contentStateRelay: BehaviorRelay<WalletRegistrationContent> { get }

    /// Reflects errors received from the JS layer
    var error: Observable<String> { get }

    func prepare() throws

    /// Executes the registration (creation / recovery)
    func execute() throws
}
