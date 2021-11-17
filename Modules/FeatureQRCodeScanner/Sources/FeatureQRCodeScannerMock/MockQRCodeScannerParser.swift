// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureQRCodeScannerDomain

final class MockQRCodeScannerParser: QRCodeScannerParsing {

    enum MockParserError: Error {
        case unknown
    }

    var underlyingParse: (Result<String, QRScannerError>) -> Result<QRCodeScannerResultType, QRScannerError> = { result in
        guard case .success(let scannedString) = result else {
            return .failure(.unknown)
        }
        return .success(.deepLink(scannedString))
    }

    func parse(scanResult: Result<String, QRScannerError>) -> AnyPublisher<QRCodeScannerResultType, QRScannerError> {
        scanResult
            .flatMap { [underlyingParse] _ -> Result<QRCodeScannerResultType, QRScannerError> in
                underlyingParse(scanResult).mapError(QRScannerError.parserError)
            }
            .publisher
            .eraseToAnyPublisher()
    }
}
