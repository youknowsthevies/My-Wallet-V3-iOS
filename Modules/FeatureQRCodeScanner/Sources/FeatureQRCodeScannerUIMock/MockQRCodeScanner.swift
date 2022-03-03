// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureQRCodeScannerDomain
@testable import FeatureQRCodeScannerUI
@testable import PlatformUIKit

final class MockQRCodeScanner: QRCodeScannerProtocol {
    var qrCodePublisherSubjet = PassthroughSubject<Result<String, QRScannerError>, Never>()
    var qrCodePublisher: AnyPublisher<Result<String, QRScannerError>, Never> {
        qrCodePublisherSubjet.eraseToAnyPublisher()
    }

    func restartScanning() {}

    var videoPreviewLayer = CALayer()

    weak var delegate: QRCodeScannerDelegate?

    var startReadingQRCodeCalled: () -> Void = {}
    var startReadingQRCodeCallCount: Int = 0

    func configure(with deviceInput: CaptureInputProtocol) {
    }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        startReadingQRCodeCallCount += 1
        startReadingQRCodeCalled()
    }

    var handleSelectedQRImageCalled: () -> Void = {}
    var handleSelectedQRImageCallCount: Int = 0

    func handleSelectedQRImage(_ image: UIImage) {
        handleSelectedQRImageCallCount += 1
        handleSelectedQRImageCalled()
    }

    var stopReadingQRCodeCalled: () -> Void = {}
    var stopReadingQRCodeCallCount: Int = 0

    func stopReadingQRCode(complete: (() -> Void)?) {
        stopReadingQRCodeCallCount += 1
        stopReadingQRCodeCalled()
        complete?()
    }
}
