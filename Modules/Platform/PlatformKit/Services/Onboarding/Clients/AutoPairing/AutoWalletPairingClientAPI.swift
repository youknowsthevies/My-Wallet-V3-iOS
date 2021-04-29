// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AutoWalletPairingClientAPI: class {
    func request(guid: String) -> Single<String>
}
