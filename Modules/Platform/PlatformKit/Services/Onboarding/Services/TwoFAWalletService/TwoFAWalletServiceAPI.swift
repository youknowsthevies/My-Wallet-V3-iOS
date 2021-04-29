// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol TwoFAWalletServiceAPI: class {
    func send(code: String) -> Completable
}
