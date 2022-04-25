// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import EthereumKit
import Foundation

public protocol WalletConnectPublicKeyProviderAPI {
    func publicKey(network: EVMNetwork) -> AnyPublisher<String, Error>
}
