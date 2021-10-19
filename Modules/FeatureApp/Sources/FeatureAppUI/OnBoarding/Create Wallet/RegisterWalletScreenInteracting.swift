// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

/// Content for wallet registration (creation / recovery)
public struct WalletRegistrationContent {
    var email = ""
    var password = ""

    public init(
        email: String = "",
        password: String = ""
    ) {
        self.email = email
        self.password = password
    }
}

public protocol RegisterWalletScreenInteracting: AnyObject {

    /// Content relay
    var contentStateRelay: BehaviorRelay<WalletRegistrationContent> { get }

    /// Reflects errors received from the JS layer
    var error: Observable<String> { get }

    func prepare() -> Result<Void, Error>

    /// Executes the registration (creation / recovery)
    func execute() -> Result<Void, Error>
}
