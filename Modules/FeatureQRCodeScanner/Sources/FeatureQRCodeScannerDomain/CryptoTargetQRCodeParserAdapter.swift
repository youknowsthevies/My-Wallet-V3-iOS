// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public protocol CryptoTargetQRCodeParserAdapter {

    var availableAccounts: AnyPublisher<[BlockchainAccount], QRScannerError> { get }

    func create(
        fromString string: String?,
        account: CryptoAccount
    ) -> AnyPublisher<QRCodeParserTarget, QRScannerError>

    func createAndValidate(
        fromString string: String?,
        account: CryptoAccount
    ) -> AnyPublisher<QRCodeParserTarget, QRScannerError>

    func presentAccountPicker(
        accounts: [QRCodeParserTarget]
    ) -> AnyPublisher<QRCodeParserTarget, QRScannerError>
}
