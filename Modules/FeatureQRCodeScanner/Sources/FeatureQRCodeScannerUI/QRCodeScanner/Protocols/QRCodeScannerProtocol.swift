// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureQRCodeScannerDomain
import UIKit

protocol QRCodeScannerProtocol: AnyObject {
    var videoPreviewLayer: CALayer { get }
    var qrCodePublisher: AnyPublisher<Result<String, QRScannerError>, Never> { get }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea)
    func restartScanning()
    func stopReadingQRCode(complete: (() -> Void)?)
    func handleSelectedQRImage(_ image: UIImage)
}
