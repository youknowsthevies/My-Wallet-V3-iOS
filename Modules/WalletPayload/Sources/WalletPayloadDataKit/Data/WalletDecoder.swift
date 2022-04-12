// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import WalletPayloadKit

final class WalletDecoder: WalletDecoderAPI {

    func createWallet(from walletPayload: WalletPayload, decryptedData: Data) -> AnyPublisher<Wrapper, WalletError> {
        decode(data: decryptedData)
            .map(NativeWallet.from(blockchainWallet:))
            .map { wallet in
                Wrapper(walletPayload: walletPayload, wallet: wallet)
            }
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
