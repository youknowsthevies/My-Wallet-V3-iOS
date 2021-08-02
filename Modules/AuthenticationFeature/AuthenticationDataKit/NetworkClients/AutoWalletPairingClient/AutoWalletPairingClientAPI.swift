// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AutoWalletPairingClientAPI: AnyObject {
    func request(guid: String) -> Single<String>
}
