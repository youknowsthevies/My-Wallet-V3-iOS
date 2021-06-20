// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol WalletPayloadClientAPI: AnyObject {
    func payload(guid: String,
                 identifier: WalletPayloadClient.Identifier) -> Single<WalletPayloadClient.ClientResponse>
}
