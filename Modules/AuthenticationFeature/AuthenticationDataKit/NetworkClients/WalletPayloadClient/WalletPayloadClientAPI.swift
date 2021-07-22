// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol WalletPayloadClientCombineAPI: AnyObject {
    /// request a wallet payload from the client which contains different data for decryption
    /// - Parameters guid: wallet guid from user
    /// - Parameters identifier: session token (password login) or sharedkey (PIN login)
    /// - Returns: A combine `Publisher` that emits a ClientResponse on success or ClientError on failure
    func payloadPublisher(
        guid: String,
        identifier: WalletPayloadClient.Identifier
    ) -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadClient.ClientError>
}

public protocol WalletPayloadClientAPI: WalletPayloadClientCombineAPI {
    func payload(
        guid: String,
        identifier: WalletPayloadClient.Identifier
    ) -> Single<WalletPayloadClient.ClientResponse>
}
