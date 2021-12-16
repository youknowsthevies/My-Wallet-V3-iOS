// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol AutoWalletPairingRepositoryAPI {

    func pair(using pairingData: PairingData) -> AnyPublisher<String, AutoWalletPairingServiceError>

    func encryptionPhrase(using guid: String) -> AnyPublisher<String, AutoWalletPairingServiceError>
}
