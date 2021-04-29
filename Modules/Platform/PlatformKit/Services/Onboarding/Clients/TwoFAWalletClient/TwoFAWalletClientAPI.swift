// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import WalletPayloadKit

public protocol TwoFAWalletClientAPI: class {
    func payload(guid: String, sessionToken: String, code: String) -> Single<WalletPayloadWrapper>
}
