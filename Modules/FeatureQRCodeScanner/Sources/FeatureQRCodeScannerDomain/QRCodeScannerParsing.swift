// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol QRCodeScannerParsing {
    func parse(scanResult: Result<String, QRScannerError>) -> AnyPublisher<QRCodeScannerResultType, QRScannerError>
}
