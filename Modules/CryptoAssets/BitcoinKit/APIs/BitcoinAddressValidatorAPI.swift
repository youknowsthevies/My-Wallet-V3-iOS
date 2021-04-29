// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol BitcoinAddressValidatorAPI {
    func validate(address: String) -> Completable
}

