// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardChargeClientAPI: class {
    func chargeCard(by id: String) -> Completable
}
