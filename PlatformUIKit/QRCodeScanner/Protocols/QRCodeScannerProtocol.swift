//
//  QRCodeScannerProtocol.swift
//  PlatformUIKit
//
//  Created by Paulo on 25/02/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

public protocol QRCodeScannerProtocol: AnyObject {
    var videoPreviewLayer: CALayer { get }
    var delegate: QRCodeScannerDelegate? { get set }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea)
    func stopReadingQRCode(complete: (() -> Void)?)
    func handleSelectedQRImage(_ image: UIImage)
}
