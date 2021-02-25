//
//  MockQRCodeScanner.swift
//  TestKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import PlatformUIKit

final class MockQRCodeScanner: QRCodeScannerProtocol {

    var videoPreviewLayer: CALayer = CALayer()

    weak var delegate: QRCodeScannerDelegate?

    var startReadingQRCodeCalled: () -> Void = { }
    var startReadingQRCodeCallCount: Int = 0
    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        startReadingQRCodeCallCount += 1
        startReadingQRCodeCalled()
    }

    var handleSelectedQRImageCalled: () -> Void = { }
    var handleSelectedQRImageCallCount: Int = 0
    func handleSelectedQRImage(_ image: UIImage) {
        handleSelectedQRImageCallCount += 1
        handleSelectedQRImageCalled()
    }

    var stopReadingQRCodeCalled: () -> Void = { }
    var stopReadingQRCodeCallCount: Int = 0
    func stopReadingQRCode(complete: (() -> Void)?) {
        stopReadingQRCodeCallCount += 1
        stopReadingQRCodeCalled()
        complete?()
    }
}
