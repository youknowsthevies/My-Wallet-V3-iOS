// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AuthenticationKit
import Combine
import RxSwift
import WalletPayloadKit

public protocol TwoFAWalletClientCombineAPI: AnyObject {
    func payloadPublisher(
        guid: String,
        sessionToken: String,
        code: String
    ) -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletServiceError>
}

public protocol TwoFAWalletClientAPI: TwoFAWalletClientCombineAPI {
    func payload(guid: String, sessionToken: String, code: String) -> Single<WalletPayloadWrapper>
}
