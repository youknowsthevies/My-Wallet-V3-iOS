// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit

public protocol MnemonicComponentsProviding {

    /// Provides 12 word components of mnemonic
    var components: AnyPublisher<[String], MnemonicAccessError> { get }
}

final class MnemonicComponentsProvider: MnemonicComponentsProviding {

    var components: AnyPublisher<[String], MnemonicAccessError> {
        mnemonicAccessAPI.mnemonic
            .map { $0.components(separatedBy: " ") }
            .eraseToAnyPublisher()
    }

    private let mnemonicAccessAPI: MnemonicAccessAPI

    init(mnemonicAccessAPI: MnemonicAccessAPI = resolve()) {
        self.mnemonicAccessAPI = mnemonicAccessAPI
    }
}
