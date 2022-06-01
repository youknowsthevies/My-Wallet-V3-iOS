// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Errors

public protocol AutoWalletPairingClientAPI: AnyObject {

    func request(guid: String) -> AnyPublisher<String, NetworkError>
}
