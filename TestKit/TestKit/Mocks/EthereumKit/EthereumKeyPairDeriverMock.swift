// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import PlatformKit
import RxSwift

class EthereumKeyPairDeriverMock: KeyPairDeriverAPI {
    var deriveResult: Result<EthereumKeyPair, Error> = .success(
        MockEthereumWalletTestData.keyPair
    )
    var lastMnemonic: String?
    func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, Error> {
        lastMnemonic = input.mnemonic
        return deriveResult
    }
}
