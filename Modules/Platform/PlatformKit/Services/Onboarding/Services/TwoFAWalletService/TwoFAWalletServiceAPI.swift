// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol TwoFAWalletServiceAPI: AnyObject {
    func send(code: String) -> Completable
}
