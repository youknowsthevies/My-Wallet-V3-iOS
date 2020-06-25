//
//  EthereumKeyPairDeriverMock.swift
//  EthereumKitTests
//
//  Created by Jack on 03/05/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import BigInt
@testable import EthereumKit
@testable import PlatformKit
import RxSwift
import web3swift

class EthereumKeyPairDeriverMock: KeyPairDeriverAPI {
    var deriveResult: Result<EthereumKeyPair, Error> = .success(
        MockEthereumWalletTestData.keyPair
    )
    var lastMnemonic: String?
    var lastPassword: String?
    func derive(input: EthereumKeyDerivationInput) -> Result<EthereumKeyPair, Error> {
        lastMnemonic = input.mnemonic
        lastPassword = input.password
        return deriveResult
    }
}
