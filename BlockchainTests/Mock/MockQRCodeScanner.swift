//
//  MockQRCodeScanner.swift
//  BlockchainTests
//
//  Created by Jack on 19/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import ToolKit

@testable import Blockchain
import PlatformKit

class MockParser: QRCodeScannerParsing {
    
    enum MockParserError: Error {
        case unknown
    }
    
    struct Model: Equatable {
        let value: String
    }
    
    var _parse: (Result<String, QRScannerError>) -> Result<Model, MockParserError> = {
        result in
        
        guard case .success(let scannedString) = result else {
            return .failure(.unknown)
        }
        return .success(Model(value: scannedString))
    }
    func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<Model, MockParserError>) -> Void)?) {
        completion?(_parse(scanResult))
    }
}

class MockQRScannableArea: QRCodeScannableArea {
    var area: CGRect {
        .zero
    }
}

class MockScanner: QRCodeScannerProtocol {
    
    var videoPreviewLayer: CALayer = CALayer()
    
    weak var delegate: QRCodeScannerDelegate?
    
    var startReadingQRCodeCalled: () -> Void = { }
    var startReadingQRCodeCallCount: Int = 0
    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        startReadingQRCodeCallCount += 1
        startReadingQRCodeCalled()
    }
    
    func handleSelectedQRImage(_ image: UIImage) {
        unimplemented()
    }
    
    var stopReadingQRCodeCalled: () -> Void = { }
    var stopReadingQRCodeCallCount: Int = 0
    func stopReadingQRCode(complete: (() -> Void)?) {
        stopReadingQRCodeCallCount += 1
        stopReadingQRCodeCalled()
        complete?()
    }
}

class MockScannerTextViewModel: QRCodeScannerTextViewModel {
    var loadingText: String? = "loadingText"
    var headerText: String = "headerText"
}
