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

    func prepare() -> Result<Void, Error>

    /// Executes the registration (creation / recovery)
    func execute() -> Result<Void, Error>
}
