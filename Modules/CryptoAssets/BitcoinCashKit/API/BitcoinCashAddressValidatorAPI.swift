// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol BitcoinCashAddressValidatorAPI {
    func validate(address: String) -> Completable
}
