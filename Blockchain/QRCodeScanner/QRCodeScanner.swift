//
//  GenericDeviceCapture.swift
//  Blockchain
//
//  Created by Jack Pooley on 13/02/2019.
//  Copyright © 2019 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import PlatformKit
import PlatformUIKit

enum QRScannerError: Error {
    case unknown
    case avCaptureError(AVCaptureDeviceError)
    case badMetadataObject
}

protocol QRCodeScannerDelegate: class {
    func scanComplete(with result: Result<String, QRScannerError>)
    func didStartScanning()
    func didStopScanning()
}

extension QRCodeScannerDelegate {
    func didStartScanning() {}
}

protocol QRCodeScannerProtocol: class {
    var videoPreviewLayer: CALayer { get }
    var delegate: QRCodeScannerDelegate? { get set }
    
    func startReadingQRCode(from scannableArea: QRCodeScannableArea)
    func stopReadingQRCode(complete: (() -> Void)?)
    func handleSelectedQRImage(_ image: UIImage)
}

protocol CaptureInputProtocol {
    var current: AVCaptureInput? { get }
}

extension AVCaptureInput: CaptureInputProtocol {
    var current: AVCaptureInput? {
        self
    }
}

protocol CaptureOutputProtocol: class {
    var current: AVCaptureOutput? { get }
}

extension AVCaptureOutput: CaptureOutputProtocol {
    var current: AVCaptureOutput? {
        self
    }
}

protocol CaptureSessionProtocol: class {
    var current: AVCaptureSession? { get }
    var sessionPreset: AVCaptureSession.Preset { get set }
    
    func startRunning()
    func stopRunning()
    
    func add(input: CaptureInputProtocol)
    func add(output: CaptureOutputProtocol)
}

extension AVCaptureSession: CaptureSessionProtocol {
    var current: AVCaptureSession? {
        self
    }
    
    func add(input: CaptureInputProtocol) {
        addInput(input.current!)
    }
    
    func add(output: CaptureOutputProtocol) {
        addOutput(output.current!)
    }
}

@objc final class QRCodeScanner: NSObject, QRCodeScannerProtocol, AVCaptureMetadataOutputObjectsDelegate {
    
    weak var delegate: QRCodeScannerDelegate?
    
    let videoPreviewLayer: CALayer
    
    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer {
        videoPreviewLayer as! AVCaptureVideoPreviewLayer
    }
    
    private let captureSession: CaptureSessionProtocol
    private let captureMetadataOutput: AVCaptureMetadataOutput = .init()
    private let sessionQueue: DispatchQueue
    
    required init?(
        deviceInput: CaptureInputProtocol? = QRCodeScanner.runDeviceInputChecks(alertViewPresenter: resolve()),
        captureSession: CaptureSessionProtocol = AVCaptureSession(),
        sessionQueue: DispatchQueue = DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.sessionQueue", qos: .background)
    ) {
        guard let deviceInput = deviceInput else { return nil }
        
        captureSession.sessionPreset = .high
        self.captureSession = captureSession
        self.sessionQueue = sessionQueue
        
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession.current!)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = videoPreviewLayer
        
        super.init()
        
        self.sessionQueue.async { [weak self] in
            self?.configure(with: deviceInput)
        }
    }
    
    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        let frame = scannableArea.area
        sessionQueue.async { [weak self] in
            self?.captureSession.current?.commitConfiguration()
            self?.captureSession.startRunning()
            self?.captureMetadataOutput.rectOfInterest = self?.captureVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: frame) ?? .zero

            DispatchQueue.main.async {
                self?.delegate?.didStartScanning()
            }
        }
    }
    
    func stopReadingQRCode(complete: (() -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()

            DispatchQueue.main.async {
                self?.delegate?.didStopScanning()
                complete?()
            }
        }
    }
    
    func handleSelectedQRImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            handleQRImageSelectionError()
            return
        }
        let ciImage = CIImage(cgImage: cgImage)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let stringValue = detector?.features(in: ciImage).compactMap { feature in
            (feature as? CIQRCodeFeature)?.messageString
        }.first
        guard let value = stringValue else {
            handleQRImageSelectionError()
            return
        }
        stopReadingQRCode { [weak self] in
            self?.delegate?.scanComplete(with: .success(value))
        }
    }
    
    private func handleQRImageSelectionError() {
        delegate?.scanComplete(with: .failure(.unknown))
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !metadataObjects.isEmpty,
            let metadataObject = metadataObjects.first,
            metadataObject.type == .qr,
            let codeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
            let stringValue = codeObject.stringValue else {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.scanComplete(with: .failure(QRScannerError.badMetadataObject))
            }
            return
        }
        stopReadingQRCode { [weak self] in
            self?.delegate?.scanComplete(with: .success(stringValue))
        }
    }
    
    /// Check if the device input is accessible for scanning QR codes
    static func runDeviceInputChecks(alertViewPresenter: AlertViewPresenter) -> AVCaptureDeviceInput? {
        switch QRCodeScanner.deviceInput() {
        case .success(let deviceInput):
            return deviceInput
        case .failure(let scanError):
            guard case .avCaptureError(let error) = scanError else {
                alertViewPresenter.standardError(message: scanError.localizedDescription)
                return nil
            }
            
            switch error.type {
            case .failedToRetrieveDevice, .inputError:
                alertViewPresenter.standardError(message: error.localizedDescription)
            case .notAuthorized:
                alertViewPresenter.showNeedsCameraPermissionAlert()
            default:
                alertViewPresenter.standardError(message: error.localizedDescription)
            }
            
            return nil
        }
    }
    
    private static func deviceInput() -> Result<AVCaptureDeviceInput, QRScannerError> {
        do {
            let input = try AVCaptureDeviceInput.deviceInputForQRScanner()
            return .success(input)
        } catch {
            guard let error = error as? AVCaptureDeviceError else {
                return .failure(.unknown)
            }
            return .failure(.avCaptureError(error))
        }
    }
    
    private func configure(with deviceInput: CaptureInputProtocol) {
        captureSession.add(input: deviceInput)
        captureSession.add(output: captureMetadataOutput)
        
        let captureQueue = DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.captureQueue")
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: captureQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }
}
