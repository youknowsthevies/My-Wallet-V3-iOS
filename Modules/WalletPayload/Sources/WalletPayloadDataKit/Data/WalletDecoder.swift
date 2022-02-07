// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletPayloadKit

final class WalletDecoder: WalletDecoderAPI {

    func createWallet(from data: Data) -> AnyPublisher<NativeWallet, WalletError> {
        decode(data: data)
            .map(NativeWallet.from(blockchainWallet:))
            .eraseToAnyPublisher()
    }

    func decode(data: Data) -> AnyPublisher<WalletResponse, WalletError> {
        Result {
            try JSONDecoder().decode(WalletResponse.self, from: data)
        }
        .mapError { WalletError.decryption(.decodeError($0)) }
        .publisher
        .eraseToAnyPublisher()
    }
}
