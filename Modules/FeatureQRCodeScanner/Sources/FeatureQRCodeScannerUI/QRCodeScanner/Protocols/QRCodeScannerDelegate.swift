// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureQRCodeScannerDomain

protocol QRCodeScannerDelegate: AnyObject {
    var scanComplete: ((Result<QRCodeScannerResultType, QRCodeScannerResultError>) -> Void)? { get set }

    func didStartScanning()
    func didStopScanning()
}
