// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureQRCodeScannerDomain
@testable import FeatureQRCodeScannerUI
import PlatformKit

final class QRCodeScannerDelegateMock: QRCodeScannerDelegate {
    var scanComplete: ((Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void)?

    func didStartScanning() {}
    func didStopScanning() {}
}
